# WHA-14 Paid Acquisition Plan and Execution Readiness

## Objective
Launch first-wave paid acquisition with measurable CAC targets, channel-level budget controls, and a 14-day test cadence that can be handed to the Performance Marketing Lead immediately after hire approval.

## North Star and Guardrails
- Primary KPI: qualified signups (or demo requests) at or below target CAC.
- Secondary KPI: cost per activated user and 7-day activation rate.
- Guardrail 1: pause any ad set with spend > 1.5x target CAC and no conversion.
- Guardrail 2: cap channel daily spend until 3 conversion events are observed per audience.
- Guardrail 3: maintain at least 20% budget for retargeting once pixel audiences are viable.

## Initial Budget Allocation (Month 1)
- Google Search: 40%
- Meta (Facebook/Instagram): 35%
- LinkedIn: 15%
- YouTube/Display retargeting: 10%

Rationale:
- Search captures in-market intent quickly.
- Meta supports rapid creative iteration at lower CPM.
- LinkedIn is controlled for high-intent B2B segments.
- Retargeting supports conversion efficiency after traffic accumulation.

## Audience and Targeting Framework
- Core ICP segments:
  - Segment A: technical evaluators and product owners.
  - Segment B: growth/ops leaders with budget influence.
- Geo priority: US first wave.
- Funnel mapping:
  - TOFU: problem-aware pain points and comparison messaging.
  - MOFU: proof-led outcomes, social proof, benchmark claims.
  - BOFU: urgency/offers, implementation speed, risk-reversal.

## Creative Testing Roadmap
- Week 1: 3 angles x 2 formats x 2 CTAs per primary channel.
- Week 2: keep top quartile creatives, replace bottom quartile with new variants.
- Creative angles:
  - Efficiency: faster execution with fewer resources.
  - Risk reduction: reliability and governance.
  - Outcome proof: measurable business lift.
- Required asset pack:
  - 6 static images
  - 4 short videos (15-30s)
  - 3 ad copy variants per angle
  - 2 landing page headline variants per audience

## Campaign Structure
- Naming convention:
  - `CHNL_REGION_FUNNEL_SEGMENT_ANGLE_FORMAT_V#`
- Separate campaigns by funnel stage.
- Separate ad sets by audience segment and geo.
- Enforce daily budget caps at ad set level.

## Measurement and Instrumentation
- Tracking requirements:
  - UTM standard for source/medium/campaign/content/term.
  - Platform pixel + server-side conversion API where available.
  - Event mapping: page_view, signup_start, signup_complete, activation.
- Reporting cadence:
  - Daily spend/conversion pulse.
  - 2x weekly optimization review.
  - Weekly executive summary with channel actions and next hypotheses.

## Optimization Playbook
- If CTR low: refresh hook/creative first.
- If CTR good, CVR low: optimize landing page match and CTA friction.
- If CVR good, CAC high: tighten targeting and shift budget to stronger segments.
- Reallocate 10-20% weekly from underperforming channels to outperformers.

## Launch Checklist
- [ ] Ad accounts, billing, and permissions verified.
- [ ] Pixel/CAPI and conversion events validated.
- [ ] UTM templates live and QA checked.
- [ ] Creative assets loaded and approved.
- [ ] Landing page variants published.
- [ ] Dashboard with KPI breakdown by channel and segment live.
- [ ] Alerting for spend spikes and conversion drop-offs configured.

## Ownership Handoff Plan
- Temporary owner: CMO (current).
- Post-hire owner: Performance Marketing Lead.
- Handoff package includes:
  - this plan,
  - campaign naming and KPI glossary,
  - test backlog (next 2 weeks),
  - budget reallocation rules,
  - active decisions log.

## Dependencies and Blockers
- Hiring dependency from parent thread (WHA-12) limits full execution ownership continuity.
- Pre-launch strategy and instrumentation planning can proceed now.
- Live channel build and ongoing optimization should be transferred immediately once Performance Marketing Lead is active.
