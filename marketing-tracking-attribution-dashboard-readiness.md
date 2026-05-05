# WHA-17 Marketing Tracking, Attribution, and Dashboard Readiness

## Objective
Define a launch-ready measurement system that supports reliable channel attribution, daily optimization decisions, and executive reporting with explicit QA and data quality controls.

## Ownership
- Temporary owner: CMO (current)
- Post-hire owner: MarketingOpsAnalyticsManager
- Related handoff dependency: `WHA-12`

## KPI Framework
- North Star:
  - Qualified signup volume at or below target blended CAC.
- Core funnel KPIs:
  - Sessions
  - Signup starts
  - Signup completes
  - Activated users (within 7 days)
  - Conversion rate (session->signup complete)
  - Activation rate (signup complete->activated)
- Channel efficiency KPIs:
  - Spend
  - CPC
  - CTR
  - CPA/CAC
  - ROAS proxy (if revenue lag exists, use activation-weighted value)

## Canonical Event Schema
Required properties on every event:
- `event_name`
- `event_time_utc`
- `anonymous_id`
- `user_id` (if known)
- `session_id`
- `page_url`
- `referrer`
- `utm_source`
- `utm_medium`
- `utm_campaign`
- `utm_content`
- `utm_term`
- `click_id` (`gclid`, `fbclid`, `li_fat_id` where available)
- `device_type`
- `country`

Required event taxonomy:
- `page_view`
- `signup_start`
- `signup_complete`
- `activation`

Validation rules:
- Event names are case-sensitive and locked.
- No null `event_time_utc`, `event_name`, or attribution fields for paid sessions.
- `signup_complete` must map to one unique `user_id`.
- `activation` must occur after `signup_complete` for same user.

## UTM and Link Governance
UTM naming contract:
- `utm_source`: platform (`google`, `meta`, `linkedin`, `youtube`, `newsletter`, `community`)
- `utm_medium`: traffic type (`cpc`, `paid_social`, `organic_social`, `email`, `referral`)
- `utm_campaign`: launch batch (`launch_q2_2026_wave1` pattern)
- `utm_content`: creative id (`angle_format_variant`)
- `utm_term`: keyword or audience segment

Governance controls:
- Single source-of-truth UTM matrix managed in sheet/notion.
- No custom/manual campaign links outside approved matrix.
- QR/short links must resolve to full UTM destination.

## Attribution Model Readiness
Models to compute in dashboard:
- Last non-direct click (primary for paid optimization)
- First touch (demand-gen trend)
- Linear multi-touch (assist visibility)

Attribution windows:
- Click-through: 7-day and 30-day views
- View-through (where available): 1-day

Channel mapping rules:
- Normalize variant source labels to canonical list.
- Bucket unknown source as `unmapped` and alert if share > 5%.

## Data Quality and QA Controls
Daily automated checks:
- Event volume anomaly: alert when event count deviates +/-40% vs trailing 7-day average.
- Attribution completeness: paid sessions with missing UTM/click_id < 3%.
- Funnel continuity: `signup_start` >= `signup_complete` and `signup_complete` >= `activation`.
- Spend alignment: ad platform spend vs warehouse spend delta < 10% per channel/day.

Pre-launch QA checklist:
- [ ] Fire all required events in staging and production.
- [ ] Confirm identity stitching from anonymous to authenticated user.
- [ ] Validate UTM persistence across redirects and signup flow.
- [ ] Validate pixel + CAPI/server conversion parity where supported.
- [ ] Confirm dashboard refresh SLA and timezone correctness (UTC + business timezone view).
- [ ] Confirm channel mapping table has no uncategorized active campaigns.

Incident response:
- P1: missing conversion events or broken spend ingestion -> page CMO + engineering same day.
- P2: attribution drift >10% but conversions intact -> triage within 24h.

## Dashboard Readiness Spec
Dashboard tabs:
- Executive Summary
  - Spend, signups, CAC, activation, trend vs prior period.
- Channel Performance
  - Channel x campaign x audience breakdown.
- Funnel Health
  - Session->signup->activation drop-offs by segment.
- Attribution Views
  - First touch / last touch / linear comparison.
- Data Quality
  - QA pass rate, anomalies, unmapped source share, pipeline freshness.

Required filters:
- Date range
- Channel
- Campaign
- Audience segment
- Geo

Refresh and latency standards:
- Launch week: refresh every 4 hours.
- Post-launch baseline: daily refresh by 9:00 UTC.
- Data freshness SLA displayed on dashboard header.

## Launch Decision Thresholds
- Scale spend on channel when:
  - >= 3 attributed conversions and CAC <= target for 2 consecutive days.
- Hold channel when:
  - CAC between 1.0x and 1.5x target with stable conversion rate.
- Pause channel/ad set when:
  - Spend > 1.5x target CAC and zero conversions.

## Handoff Package to MarketingOpsAnalyticsManager
- Tracking dictionary (events + properties + owner)
- UTM matrix and governance rules
- Attribution logic definitions and SQL/model links
- Dashboard URL(s), permissions map, and refresh schedule
- QA monitor alert routing and escalation contacts

## Dependencies and Risks
- Dependency: hiring completion in `WHA-12` for long-term owner transfer.
- Risk: temporary CMO ownership may limit deep instrumentation iteration speed.
- Mitigation: lock schema, automate QA checks, and document model logic before handoff.
