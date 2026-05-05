# WHA-21 Paid Campaign UTM Matrix Validation

## Objective
Validate that all active paid campaign destination URLs conform to the approved UTM matrix and that click IDs (`gclid`, `fbclid`, `li_fat_id`) are captured where supported.

## Approved UTM Matrix Contract

| Parameter | Allowed Values | Example |
|---|---|---|
| `utm_source` | `google`, `meta`, `linkedin`, `youtube` | `google` |
| `utm_medium` | `cpc`, `paid_social` | `cpc` |
| `utm_campaign` | `launch_q2_2026_wave1` pattern | `launch_q2_2026_wave1` |
| `utm_content` | `{angle}_{format}_{variant}` | `anxiety_relief_video_v1` |
| `utm_term` | keyword or audience segment | `anxiety+quiz` or `lookalike_1pct` |

## Click-ID Capture Requirements

| Platform | Click ID Param | Capture Required |
|---|---|---|
| Google Ads | `gclid` | Yes |
| Meta Ads | `fbclid` | Yes |
| LinkedIn Ads | `li_fat_id` | Yes (where available) |
| YouTube Ads | `gclid` | Yes (uses Google infra) |

## Validation Checks

### Check 1: UTM Completeness
- [ ] Every paid destination URL contains all 5 required UTM parameters
- [ ] No parameter is empty or set to placeholder values
- [ ] Values match approved patterns in the matrix above

### Check 2: UTM Conformity
- [ ] `utm_source` matches canonical platform list
- [ ] `utm_medium` matches traffic type for the platform
- [ ] `utm_campaign` follows `launch_q2_2026_wave*` naming
- [ ] `utm_content` follows `{angle}_{format}_{variant}` structure
- [ ] `utm_term` is populated for search campaigns

### Check 3: Click-ID Infrastructure
- [ ] Landing page JS reads and stores `gclid` from URL params
- [ ] Landing page JS reads and stores `fbclid` from URL params
- [ ] Landing page JS reads and stores `li_fat_id` from URL params (if LinkedIn traffic)
- [ ] Click IDs are passed to analytics events as `click_id` property
- [ ] Click IDs persist through signup flow (session/local storage)

### Check 4: Redirect Handling
- [ ] If any redirect exists between ad click and final LP, UTMs survive the redirect
- [ ] Click ID params survive any redirect chain
- [ ] No redirect strips query parameters

## Evidence Collection Template

For each platform (Google, Meta, LinkedIn):

1. Export all active campaign destination URLs
2. Populate `wha-25-active-paid-destination-url-export-template.csv`
3. Run automated UTM validation against matrix rules
4. Spot-check 5 URLs per platform by clicking and verifying landing page receives params
5. Check analytics event sample (10+ paid sessions) for:
   - All 5 UTM fields populated
   - Click ID captured
   - UTM values match source ad platform

## Pass Criteria
- 100% of active paid URLs pass UTM completeness check
- 100% of active paid URLs pass UTM conformity check
- <3% of paid sessions have missing UTM or click ID in analytics
- Click IDs captured for >95% of sessions where platform supports them

## Status
**Blocked** - Requires live ad platform access and analytics warehouse access to collect evidence.

## Dependencies
- Ad platform access (Google Ads, Meta Ads Manager, LinkedIn Campaign Manager)
- Analytics warehouse or dashboard with session-level event data
- Ability to test live destination URLs
