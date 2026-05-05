# WHA-21 Validation Report: UTM Matrix + Click-ID Capture

**Status**: PASS  
**Validation Date**: 2026-05-05  
**Validator**: Performance Marketing Lead (`75bc0bc3-5895-4577-baa7-21c25b90e0aa`)

---

## Evidence Sources

| Source | File | Description |
|--------|------|-------------|
| [WHA-24](/WHA/issues/WHA-24) | `wha-24-utm-audit-report.md` | UTM matrix conformance audit (10 URLs) |
| [WHA-24](/WHA/issues/WHA-24) | `wha-25-active-paid-destination-url-export.csv` | Active paid URL export (10 URLs) |
| [WHA-23](/WHA/issues/WHA-23) | `wha-23-paid-session-utm-extract.csv` | Paid-session UTM warehouse extract (10 sessions) |
| [WHA-23](/WHA/issues/WHA-23) | `wha-23-utm-persistence-sample.md` | UTM persistence through redirect + signup flow |
| [WHA-23](/WHA/issues/WHA-23) | `wha-23-evidence-package.md` | Evidence package summary with aggregate metrics |

---

## Check 1: UTM Completeness — PASS

**Criteria**: 100% of active paid destination URLs contain all 5 required UTM parameters

| Platform | URLs Audited | Complete | Status |
|----------|-------------|----------|--------|
| Google Ads | 4 | 4 (100%) | ✅ |
| YouTube Ads | 1 | 1 (100%) | ✅ |
| Meta Ads | 3 | 3 (100%) | ✅ |
| LinkedIn Ads | 2 | 2 (100%) | ✅ |
| **Total** | **10** | **10 (100%)** | **✅ PASS** |

---

## Check 2: UTM Conformity — PASS

**Criteria**: All UTM values match approved patterns

| Parameter | Allowed Values | Evidence | Status |
|-----------|---------------|----------|--------|
| `utm_source` | `google`, `meta`, `linkedin`, `youtube` | All values canonical | ✅ |
| `utm_medium` | `cpc`, `paid_social` | Google=cpc, Meta/LinkedIn=paid_social | ✅ |
| `utm_campaign` | `launch_q2_2026_wave1` pattern | All match | ✅ |
| `utm_content` | `{angle}_{format}_{variant}` | All 10 conform | ✅ |
| `utm_term` | keyword or audience segment | All populated | ✅ |

All 10 `utm_content` values parsed correctly:
- `anxiety_relief_video_v1` → angle: anxiety_relief, format: video, variant: v1
- `sleep_solution_video_v2` → angle: sleep_solution, format: video, variant: v2
- `mindfulness_app_video_v1` → angle: mindfulness_app, format: video, variant: v1
- `anxiety_quiz_v1` → angle: anxiety, format: quiz, variant: v1
- `guided_meditation_video_v1` → angle: guided_meditation, format: video, variant: v1
- `sleep_solution_image_v2` → angle: sleep_solution, format: image, variant: v2
- `anxiety_relief_image_v3` → angle: anxiety_relief, format: image, variant: v3
- `stress_relief_video_v1` → angle: stress_relief, format: video, variant: v1
- `stress_management_carousel_v1` → angle: stress_management, format: carousel, variant: v1
- `productivity_boost_carousel_v2` → angle: productivity_boost, format: carousel, variant: v2

---

## Check 3: Click-ID Infrastructure — PASS

**Criteria**: Click IDs captured where platform supports

| Platform | Click ID | Destination URLs | Session Capture | Status |
|----------|----------|-----------------|-----------------|--------|
| Google Ads | `gclid` | Present (4 URLs) | Captured (5 sessions) | ✅ |
| YouTube Ads | `gclid` | Present (1 URL) | Included in Google | ✅ |
| Meta Ads | `fbclid` | Present (3 URLs) | Captured (3 sessions) | ✅ |
| LinkedIn Ads | `li_fat_id` | Present (2 URLs) | Captured (2 sessions) | ✅ |

Session-level evidence:
- 3-channel redirect/signup tests: 100% UTM persistence, 100% click-ID preservation
- Warehouse extract confirms click IDs stored in session events

---

## Check 4: Redirect Handling — PASS

**Criteria**: UTMs and click IDs survive redirect chains

| Test | Channel | UTMs Survived | Click-ID Survived | Status |
|------|---------|--------------|-------------------|--------|
| Test 1 | Google Ads → LP → Signup | 5/5 | gclid | ✅ |
| Test 2 | Meta Ads → LP → Signup | 5/5 | fbclid | ✅ |
| Test 3 | LinkedIn Ads → LP → Signup | 5/5 | li_fat_id | ✅ |

All 3 tests: 100% UTM persistence through redirect + signup flow

---

## Analytics Warehouse Aggregate Metrics

| Metric | Count | Percentage | Threshold | Status |
|--------|-------|------------|-----------|--------|
| Total paid sessions | 1,247 | — | — | — |
| Complete UTMs | 1,210 | 97.0% | — | — |
| Click IDs captured | 1,189 | 95.3% | >95% | ✅ |
| Missing attribution | 37 | 2.97% | <3% | ✅ |

**Both aggregate thresholds met.**

---

## Final Verdict

| Check | Result |
|-------|--------|
| UTM Completeness | PASS |
| UTM Conformity | PASS |
| Click-ID Infrastructure | PASS |
| Redirect Handling | PASS |
| Missing attribution < 3% | PASS (2.97%) |
| Click-ID capture > 95% | PASS (95.3%) |

**WHA-21: ALL CHECKS PASS**
