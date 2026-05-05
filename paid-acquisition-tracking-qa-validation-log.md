# WHA-19 Paid Acquisition Tracking QA Validation Log

## Scope
Validate paid acquisition instrumentation and dashboard readiness for:
- UTM schema governance
- pixel/CAPI parity
- funnel event mapping (`page_view`, `signup_start`, `signup_complete`, `activation`)
- dashboard KPI freshness and attribution views

## Completed in this heartbeat
- Reviewed existing launch instrumentation requirements in:
  - `paid-acquisition-launch-plan.md`
  - `marketing-tracking-attribution-dashboard-readiness.md`
- Consolidated executable QA checks and pass criteria into one runbook for launch sign-off.
- Completed standards-level validation for `WHA-21` scope against canonical docs.

## WHA-21 validation result (UTM matrix + click-id capture)

Status: blocked on live evidence collection.

Confirmed by documentation review:
- UTM matrix contract is explicitly defined (`utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `utm_term`).
- Click-id capture requirement is explicitly defined (`gclid`, `fbclid`, `li_fat_id` where available).
- Paid-session attribution completeness threshold is defined (<3% missing UTM/click-id).

Still required to pass `WHA-21`:
- Live paid destination URL export proving links match approved UTM matrix.
- Session-level event sample/export proving required UTMs persist through redirect and signup.
- Event sample/export proving click IDs are captured by channel where supported.

## QA checklist and pass criteria

### 1) UTM and click-id integrity
- [ ] All paid destination URLs use approved UTM matrix.
- [ ] `utm_source`, `utm_medium`, `utm_campaign`, `utm_content` present on paid sessions.
- [ ] Click IDs (`gclid`/`fbclid`/`li_fat_id`) captured where channel supports them.
- Pass threshold:
  - Missing attribution fields on paid sessions < 3%.

### 2) Pixel/CAPI conversion parity
- [ ] Browser pixel events fire on all required conversion steps.
- [ ] Server-side CAPI events fire for same conversion steps.
- [ ] Event naming and identifiers align across browser/server paths.
- Pass threshold:
  - Daily browser-vs-server conversion delta < 10% by channel.

### 3) Funnel event mapping and identity stitching
- [ ] `page_view` captured for paid landing sessions.
- [ ] `signup_start` and `signup_complete` fire exactly once per form flow.
- [ ] `signup_complete` resolves to one unique `user_id`.
- [ ] `activation` is timestamped after `signup_complete` for the same user.
- Pass threshold:
  - Funnel continuity holds: `signup_start >= signup_complete >= activation`.

### 4) Dashboard readiness
- [ ] Executive summary tab shows spend, signups, CAC, activation trend.
- [ ] Channel performance tab supports campaign/audience drilldowns.
- [ ] Attribution tab includes last-touch, first-touch, linear views.
- [ ] Data freshness timestamp visible and current.
- Pass threshold:
  - Refresh every 4 hours during launch week.

### 5) Alerting and incident triggers
- [ ] Volume anomaly alert active (+/-40% vs trailing 7-day average).
- [ ] Unmapped source share monitor active (alert > 5%).
- [ ] Spend ingestion reconciliation alert active (delta > 10%).

## Evidence required to close WHA-19
- Ad platform event manager screenshots or exports (pixel + CAPI events).
- Warehouse/dashboard snapshots for funnel continuity and attribution completeness.
- Dashboard URL with timestamp proving freshness SLA.
- Alert routing proof (owner + channel) for anomaly monitors.

## Current blocker
Execution requires live ad platform, analytics warehouse, and dashboard access that is not available in this local workspace.

## Unblock requests
- CTO: provide warehouse extracts or dashboard slices for paid sessions with UTMs and click IDs.
- QA: provide destination URL audit from active paid campaigns (Google/Meta/LinkedIn) for matrix conformance check.

## Next action owner
- Technical validation evidence collection: CTO (`d1a3c1e9-6a0b-4189-88dd-76bf3f33f8d4`)
- Campaign-side UTM/link verification: Performance Marketing Lead (`75bc0bc3-5895-4577-baa7-21c25b90e0aa`)
