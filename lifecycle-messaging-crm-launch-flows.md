# WHA-16 Lifecycle Messaging and CRM Launch Flows

## Objective
Define launch-ready lifecycle messaging and CRM automation that improves activation, retention, and reactivation while remaining operable during temporary CMO ownership and immediately transferable to a dedicated lifecycle owner.

## Ownership
- Temporary owner: CMO (current)
- Post-hire owner: LifecycleCRMSpecialist
- Related handoff dependency: `WHA-13`

## Lifecycle KPI Framework
- Primary KPI:
  - Activated users within 7 days of signup.
- Secondary KPIs:
  - Day-7 retention rate.
  - Trial-to-paid conversion rate (if applicable).
  - Reactivation rate for dormant users.
- Operational KPIs:
  - Email deliverability (>97% delivered).
  - Open and click-through by segment.
  - Workflow completion rate and error rate.

## Audience Segmentation Model
- Lifecycle stage segments:
  - New lead (no signup)
  - New signup (0-24h)
  - Onboarding in progress (day 1-7)
  - Activated user
  - At-risk user (no key action in 7 days)
  - Dormant user (no key action in 21+ days)
- Persona overlays:
  - Technical evaluator
  - Team lead/operator
  - Growth/ops stakeholder
- Behavior overlays:
  - High-intent (multiple product views, setup started)
  - Low-intent (single session, no setup)
  - Feature-specific interest (integration/security/collaboration)

Segmentation governance:
- Segments must be rule-based and queryable in CRM.
- No one-off manual lists for launch-critical automations.
- Segment membership refreshes at least every 4 hours during launch week.

## CRM Event and Trigger Contract
Required trigger events:
- `signup_complete`
- `onboarding_step_completed`
- `activation`
- `session_inactive_3d`
- `session_inactive_7d`
- `session_inactive_21d`
- `trial_expiring_3d` (if trial motion exists)

Required trigger payload fields:
- `user_id`
- `email`
- `lifecycle_stage`
- `persona_segment`
- `utm_source`
- `utm_campaign`
- `signup_date_utc`
- `last_active_at_utc`
- `activation_flag`

Validation rules:
- Every trigger must include `user_id`, `email`, and `lifecycle_stage`.
- `activation` can only fire after `signup_complete`.
- Inactivity triggers must dedupe to one message per window per user.

## Launch Lifecycle Journey Map

### Journey A: New Signup Welcome (0-24h)
- Trigger: `signup_complete`
- Touch 1 (immediate): welcome + quick-start CTA.
- Touch 2 (+6h): setup checklist with 3 key actions.
- Touch 3 (+24h if not activated): friction-removal message with help CTA.
- Exit condition: `activation` occurs.

### Journey B: Onboarding Acceleration (day 1-7)
- Trigger: user not activated after first 24h.
- Touch 1 (day 2): role-specific use case guidance.
- Touch 2 (day 4): social proof and outcome benchmarks.
- Touch 3 (day 6): direct support / office-hours invitation.
- Exit condition: `activation` or onboarding completion.

### Journey C: Early Retention Reinforcement (day 7-21)
- Trigger: user activated.
- Touch 1 (day 8): next-value milestone recommendation.
- Touch 2 (day 12): advanced feature spotlight by persona.
- Touch 3 (day 18): habit loop prompt and team invite CTA.
- Exit condition: repeated weekly key action achieved.

### Journey D: At-Risk Rescue (7-day inactivity)
- Trigger: `session_inactive_7d`
- Touch 1: reminder anchored to unfinished value path.
- Touch 2 (+48h): objection handling and low-effort restart steps.
- Touch 3 (+96h): limited-time support incentive.
- Exit condition: session returns and key action resumes.

### Journey E: Dormant Reactivation (21+ day inactivity)
- Trigger: `session_inactive_21d`
- Touch 1: personalized recap of missed value.
- Touch 2 (+3d): product improvements/new feature relevance.
- Touch 3 (+7d): final reactivation CTA before suppression window.
- Exit condition: user reactivates or enters suppression.

## Messaging Architecture
- Message pillars:
  - Fast time-to-value.
  - Lower operational risk.
  - Clear outcome proof.
- Channel mix:
  - Primary: email.
  - Secondary: in-app messages.
  - Optional: SMS for high-intent opt-in users only.
- Personalization tokens:
  - first name, role/persona, use case, incomplete setup step, recent activity marker.

Copy guardrails:
- One core CTA per message.
- Avoid overlapping sends from multiple workflows in same 24h window.
- Enforce frequency cap: max 1 lifecycle email/day during launch week unless transactional.

## Automation Build and QA Checklist
- [ ] CRM workflows created for Journeys A-E.
- [ ] Trigger payload schema validated in staging.
- [ ] Suppression and frequency caps configured.
- [ ] Branch logic QA for activated vs non-activated users.
- [ ] UTM tagging template applied to every CTA link.
- [ ] Seed-list tests completed across major inbox providers.
- [ ] Fallback path defined for trigger ingestion failures.

Monitoring during launch week:
- Daily check of send volume by segment.
- Daily check of activation lift from Journey A/B cohorts.
- Alert if workflow error rate >2% or deliverability <97%.
- Alert if unsubscribe rate >1.0% on any sequence.

## Experiment Backlog (First 14 Days)
- Test 1: welcome email CTA framing (speed vs proof).
- Test 2: day-2 onboarding message format (checklist vs case study).
- Test 3: at-risk rescue timing (+24h vs +48h second touch).
- Test 4: reactivation incentive copy (support-led vs feature-led).

Decision rules:
- Promote variant when conversion to next milestone improves >=15% with meaningful sample.
- Sunset sequence when unsubscribe or complaint rate exceeds threshold twice.

## Handoff Package to LifecycleCRMSpecialist
- Journey maps and trigger definitions (this document).
- Template library with approved copy variants.
- Segment rule definitions and CRM query snapshots.
- Active experiment log with outcomes and next hypotheses.
- Deliverability baseline report and escalation contacts.

## Dependencies and Risks
- Dependency: hiring completion and role continuity in `WHA-13`.
- Risk: temporary ownership may slow high-frequency iteration.
- Mitigation: predefine flows, lock trigger contract, and document QA/decision thresholds for same-day owner transition.
