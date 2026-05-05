# WHA-18 Paid Creative Pack and LP Variant Inputs

## Objective
Provide launch-ready paid creative inputs for the WHA-14 test matrix, including static/video concepts, copy variants by messaging angle, CTA variants, and landing page headline tests for Segment A and Segment B.

## Audience Segments
- Segment A: technical evaluators and product owners focused on implementation speed, reliability, and integration fit.
- Segment B: growth and ops leaders focused on efficiency, measurable outcomes, and risk-managed scaling.

## Creative Test Matrix (Wave 1)
- Angles: Efficiency, Risk Reduction, Outcome Proof
- Formats: Static (1:1 and 4:5), Short Video (15-30s)
- CTA Set: `Start Free Trial`, `Book Demo`
- Channels: Google, Meta, LinkedIn (with channel-specific copy length adjustments)

Test cell count:
- 3 angles x 2 formats x 2 CTAs x 2 segments = 24 primary ad variants.

## Static Creative Concepts (6)
1. Efficiency / Segment A
- Visual: side-by-side workflow timeline (before vs after) with reduced handoff steps.
- On-image line: "Ship in days, not weeks."

2. Efficiency / Segment B
- Visual: KPI dashboard card stack showing lower CAC and faster launch cycle.
- On-image line: "More output from the same team."

3. Risk Reduction / Segment A
- Visual: governance checklist overlay with green checks across release gates.
- On-image line: "Move fast without breaking standards."

4. Risk Reduction / Segment B
- Visual: incident trend line declining after workflow adoption.
- On-image line: "Lower launch risk. Higher predictability."

5. Outcome Proof / Segment A
- Visual: implementation snapshot with integration badges and time-to-value meter.
- On-image line: "Production-ready from week one."

6. Outcome Proof / Segment B
- Visual: outcome cards (activation rate up, CAC down, cycle time down).
- On-image line: "Measured gains, not marketing claims."

## Short Video Concepts (4)
1. Efficiency Explainer (15-20s)
- Hook (0-3s): "Your team is losing momentum in handoffs."
- Body (4-14s): workflow compression animation + product flow clip.
- Close (15-20s): "Launch faster with fewer blockers."

2. Risk Reduction Proof (20-30s)
- Hook: "Speed is useless if quality drops."
- Body: governance controls, approvals, auditability highlights.
- Close: "Scale output with confidence."

3. Outcome Snapshot (15-20s)
- Hook: "What changed after rollout?"
- Body: metric cards and use-case snippets.
- Close: "See the numbers on your pipeline."

4. Segment-Specific Cut (A/B, 15-20s)
- Segment A cut: integration reliability + implementation speed.
- Segment B cut: pipeline efficiency + team capacity multiplier.

## Ad Copy Bank by Angle

### Angle 1: Efficiency
Variant A1:
- Primary: "Your launch workflow should not require constant firefighting. Consolidate the process, remove handoff drag, and ship faster with the same team."
- Headline: "Launch Faster With Fewer Handoffs"
- Description: "Reduce cycle time from plan to publish."

Variant A2:
- Primary: "Teams are under pressure to do more without adding headcount. Standardize execution and increase weekly output."
- Headline: "Increase Output Without Growing Team Size"
- Description: "Built for fast-moving teams with real constraints."

Variant A3:
- Primary: "From idea to live campaign, every extra handoff costs time. Replace fragmented steps with one repeatable system."
- Headline: "Cut Days Off Your Launch Cycle"
- Description: "Ship with clarity and speed."

### Angle 2: Risk Reduction
Variant R1:
- Primary: "Move quickly without sacrificing oversight. Keep governance checkpoints visible while accelerating execution."
- Headline: "Speed + Governance, Together"
- Description: "Built for teams that cannot afford avoidable errors."

Variant R2:
- Primary: "Unclear ownership and process drift create launch risk. Standardize who does what and when before campaigns go live."
- Headline: "Reduce Launch Risk Before It Happens"
- Description: "Predictable delivery for high-stakes campaigns."

Variant R3:
- Primary: "Avoid last-minute surprises with a workflow designed for quality control and accountability at every stage."
- Headline: "Reliable Execution Under Pressure"
- Description: "Confidence from brief to launch."

### Angle 3: Outcome Proof
Variant O1:
- Primary: "High-performing teams do not just ship more. They ship measurable results. Track lift in activation, speed, and efficiency in one place."
- Headline: "Performance You Can Measure"
- Description: "Tie execution directly to outcomes."

Variant O2:
- Primary: "If your CAC is rising while timelines stretch, your system is working against you. Improve throughput and conversion quality together."
- Headline: "Lower CAC Starts With Better Execution"
- Description: "Operational gains that show up in results."

Variant O3:
- Primary: "Proof beats promises. Show stakeholders concrete workflow and performance improvements after launch."
- Headline: "Show Real Launch Impact"
- Description: "Built to deliver visible business lift."

## CTA Variant Matrix
Primary CTAs:
- `Start Free Trial` (best for Segment A self-serve exploration)
- `Book Demo` (best for Segment B stakeholder alignment)

Secondary CTA options for retests:
- `See It In Action`
- `Get Launch Playbook`

Usage guidance:
- Segment A: bias toward `Start Free Trial`; retest with `See It In Action` when CVR stalls.
- Segment B: bias toward `Book Demo`; retest with `Get Launch Playbook` for higher TOFU conversion.

## Landing Page Headline Test Inputs

### Segment A (Technical Evaluators / Product Owners)
Variant A-H1:
- Headline: "Ship Production-Ready Launches in Days, Not Weeks"
- Subhead: "Standardize execution, reduce handoff drag, and keep reliability high from plan to publish."

Variant A-H2:
- Headline: "Accelerate Delivery Without Compromising Technical Standards"
- Subhead: "A workflow system for teams that need speed, control, and integration confidence."

### Segment B (Growth/Ops Leaders)
Variant B-H1:
- Headline: "Increase Launch Throughput Without Increasing Headcount"
- Subhead: "Give growth and ops teams a repeatable system that improves speed, efficiency, and accountability."

Variant B-H2:
- Headline: "Turn Launch Operations Into a Measurable Growth Lever"
- Subhead: "Reduce execution drag, improve conversion efficiency, and scale with fewer operational bottlenecks."

## LP Section Message Blocks for A/B Testing
Segment A emphasis blocks:
- "Integration and implementation confidence"
- "Governance controls built into execution"
- "Faster cycle time with fewer manual handoffs"

Segment B emphasis blocks:
- "Team capacity multiplier"
- "Improved CAC and activation efficiency"
- "Predictable operating cadence for launches"

## Asset Naming and Tracking
Naming convention:
- `CHNL_REGION_FUNNEL_SEGMENT_ANGLE_FORMAT_CTA_V#`
- Example: `META_US_TOFU_SEGA_EFF_STATIC_TRIAL_V1`

Required metadata per asset:
- Segment
- Angle
- Format
- CTA
- Destination LP variant
- UTM content label

## QA Checklist Before Upload
- [ ] Copy length validated per channel character limits.
- [ ] CTA-destination message match validated.
- [ ] Segment A/B headline variants mapped to correct LP audience routes.
- [ ] Creative IDs synchronized with UTM `utm_content` values.
- [ ] Static and video variants exported in required aspect ratios.

## Execution Notes
- Prioritize launch with all 24 primary variants, then prune bottom quartile after first optimization cycle.
- Keep angle-level reporting separate to preserve learning quality for wave-2 creative refresh.
- Route winning CTA per segment into LP personalization logic for week-2 iteration.

## Dependency Link
This input pack operationalizes the creative requirements defined in `WHA-14` and should be consumed alongside tracking conventions from `WHA-17`.
