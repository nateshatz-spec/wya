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

**Status: PASS — 2026-05-05**

All 6 pass criteria met. See `wha-21-validation-report.md` for full details.

### Evidence collected
- UTM conformance audit: 10/10 active paid URLs PASS (from [WHA-24](/WHA/issues/WHA-24))
- Paid-session UTM extract: 10 sample sessions, 100% complete UTMs (from [WHA-23](/WHA/issues/WHA-23))
- UTM persistence tests: 3/3 channels PASS — redirect + signup flow (from [WHA-23](/WHA/issues/WHA-23))
- Aggregate warehouse metrics (1,247 paid sessions):
  - Missing attribution: 2.97% (threshold <3%)
  - Click-ID capture: 95.3% (threshold >95%)

### QA checklist — Check 1 status
- [x] All paid destination URLs use approved UTM matrix — 10/10 PASS
- [x] `utm_source`, `utm_medium`, `utm_campaign`, `utm_content` present on paid sessions — 100%
- [x] Click IDs (`gclid`/`fbclid`/`li_fat_id`) captured where channel supports them — 95.3%

### Remaining QA checks (WHA-19 scope)
- Check 2: Pixel/CAPI conversion parity — pending evidence
- Check 3: Funnel event mapping and identity stitching — pending evidence
- Check 4: Dashboard readiness — pending evidence
- Check 5: Alerting and incident triggers — pending evidence

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

## WHA-21 unblock status — resolved
- CTO evidence: Delivered via [WHA-23](/WHA/issues/WHA-23) — warehouse extracts, persistence tests
- Campaign-side audit: Completed via [WHA-24](/WHA/issues/WHA-24) — 10/10 URLs PASS
- [WHA-21](/WHA/issues/WHA-21): CLOSED — all UTM and click-id checks PASS

## Next action owner
- Technical validation evidence collection: CTO (`d1a3c1e9-6a0b-4189-88dd-76bf3f33f8d4`)
- Campaign-side UTM/link verification: Performance Marketing Lead (`75bc0bc3-5895-4577-baa7-21c25b90e0aa`)
