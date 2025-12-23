/*
=============================================================
		GITHUB COPILOT — BUILD FULL FLUTTER UI FOR PROJECT
=============================================================
PROJECT: Ethical AI Credit Scoring App with XAI (SHAP/LIME)
STACK:
  - FRONT: Flutter (Material 3, Dart null safety, Riverpod, GoRouter)
  - BACKEND: Spring Boot REST API (Java 17)
  - AI: Python FastAPI service (SHAP, Model Predict)
  - DATABASE: MongoDB
  - QUALITY MANAGEMENT: logs, monitoring, validation, audit UI

GOAL:
Generate a COMPLETE Flutter UI that is functional, modern,
clean, professional, responsive (mobile/tablet/desktop),
and fully aligned with the Ethical AI + XAI philosophy.

=============================================================
======================== DESIGN STYLE =======================
=============================================================
- Modern fintech UI: premium gradients, glassmorphism, shadows
- Colors: elegant modern palette (blue, teal, emerald, grey)
- Support full Dark mode + Light mode
- Rounded corners (12–20 px)
- Smooth animations (implicit animations + Lottie for onboarding)
- Professional typography (Inter/Roboto)
- Dashboard-level components (cards, charts, gauges)

=============================================================
===================== GLOBAL APP STRUCTURE ==================
=============================================================
Generate two separate spaces:

1. USER SPACE (clients)
2. ADMIN SPACE (analysts, managers)

Both must have their own navigation trees.

=============================================================
========================== USER SPACE =======================
=============================================================

1. Onboarding Screens (3 screens):
	- Explain ethical AI, fair scoring, transparency.
	- Illustrations or Lottie animations.
	- Next / Skip buttons.

2. User Login & Register:
	- Glassmorphism card
	- Email, password, confirm password
	- Link: “Switch to Admin Login”

3. User Home Dashboard:
	- Welcome header with avatar
	- Current credit score preview (animated gauge)
	- Quick actions:
		  * Submit new credit application
		  * Check credit history
	- Scrollable list of past applications

4. New Credit Application (multi-step form):
	Step 1: Personal info
	Step 2: Financial info
	Step 3: Review & Submit
	- Validate fields
	- On submit → call Spring Boot API endpoint:
	  POST /api/applications

5. Score Result (after AI prediction):
	- Large animated circular score gauge (0–900)
	- Decision tag: APPROVED / REJECTED / MANUAL REVIEW
	- XAI explanation area:
			 * Horizontal bar chart (SHAP values)
			 * Green positive, red negative
			 * Text explanation: “Why this decision?”
	- Recommendation cards for user improvement.
	- Button: “Save Result” (save to MongoDB through REST)

6. Profile Screen:
	- Update personal info
	- Upload profile picture
	- Logout

=============================================================
========================== ADMIN SPACE ======================
=============================================================

Admin UI must look different: dark, high-contrast, analytic.

1. Admin Login:
	- Admin-specific branding
	- Secure look (dark blue/black theme)

2. Admin Dashboard:
	- Sidebar navigation (Dashboard, Applications, Models, Analytics)
	- Top bar with search + notifications
	- Cards showing:
		 * Total applications
		 * Approval rate
		 * Model version
		 * Fairness index

3. Applications Table:
	- Paginated
	- Columns:
		  * Customer name
		  * Score
		  * Decision
		  * Date
		  * Model version
	- Filters:
		  * Score range
		  * Status
		  * Date

4. Application Detail Page:
	- User profile card
	- Financial features card
	- SHAP explanation chart
	- Timeline of decisions
	- Button: “Override Decision” (manual review)

5. Model Monitoring Page:
	- Line chart: score drift
	- Bar chart: fairness metrics
	- Model version selector
	- Quality/Audit logs

=============================================================
==================== REUSABLE COMPONENTS ====================
=============================================================

Generate all of the following widgets:

- GradientButton
- GlassCard
- ScoreGaugeAnimatedWidget
- ShapBarChartWidget
- AppSectionTitle
- StatusBadge (approved/rejected/pending)
- ResponsiveLayout
- AppSidebar (admin)
- FintechTheme (full light + dark ThemeData)

=============================================================
========================= API INTEGRATION ==================
=============================================================
All API calls must be prepared for:
- Spring Boot endpoints:
	  POST /api/auth/login
	  POST /api/applications
	  GET  /api/applications/{id}/score
	  GET  /api/admin/applications
	  GET  /api/admin/metrics

- AI FastAPI endpoints:
	  POST /predict
	  POST /explain

Provide service classes for:
- AuthService
- ApplicationService
- AdminService
- AIService

=============================================================
================== QUALITY MANAGEMENT UI =====================
=============================================================
Add views for:
- Error logs
- API latency graphs
- Model performance over time
- Bias/Fairness dashboards
- Form validation errors

Must include:
- Snackbars
- Loading animations
- Retry buttons
- Error boundaries

=============================================================
Copilot MUST NOW generate:
- All screens
- Components
- Responsive layouts
- Themes
- Navigation with GoRouter
- Dummy data for charts + XAI
- Integration stubs for API calls
The UI must not be simple/basic.
It must be a modern, premium, real-world fintech app.

=============================================================
======================== START CODING =======================
=============================================================
*/
