/**
 * WYA 3.0 — Cloudflare Worker API
 *
 * Endpoints:
 *   POST   /api/v1/auth/signup         — Create new account
 *   POST   /api/v1/auth/login          — Sign in
 *   PUT    /api/v1/users/:userId/data  — Upsert full user data snapshot
 *   GET    /api/v1/users/:userId/data  — Retrieve user data snapshot
 *   DELETE /api/v1/users/:userId/data  — Delete all user data
 *   GET    /api/v1/health              — Health check
 */

export interface Env {
	DB: D1Database;
	API_SECRET: string; // Master secret for admin tasks
	JWT_SECRET: string; // Secret for signing user tokens
	RESEND_API_KEY: string; // API key for sending emails
}

// ---------- helpers ----------

async function sendWelcomeEmail(email: string, name: string, env: Env) {
	if (!env.RESEND_API_KEY) return;

	const html = `
		<!DOCTYPE html>
		<html>
		<head>
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<style>
				@media only screen and (max-width: 600px) {
					.container { padding: 20px !important; border-radius: 0 !important; }
					.title { font-size: 28px !important; }
					.button { width: 100% !important; box-sizing: border-box; }
				}
			</style>
		</head>
		<body style="margin: 0; padding: 0; background-color: #0b0f19;">
			<div class="container" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #0b0f19; color: #f8fafc; padding: 60px 40px; max-width: 600px; margin: 0 auto; border-radius: 30px;">
				<div style="text-align: center; margin-bottom: 40px;">
					<img src="https://whatsyouranxiety.com/logo.png" alt="WYA Logo" style="width: 100px; height: 100px;">
				</div>
				
				<h1 class="title" style="font-size: 36px; font-weight: 900; margin-bottom: 24px; text-align: center; color: white; letter-spacing: -1px; line-height: 1.1;">Welcome to the Beta, ${name}!</h1>
				
				<p style="font-size: 18px; line-height: 1.6; color: #94a3b8; margin-bottom: 32px; text-align: center;">
					We're so excited that you've decided to start your mental health journey with <strong>What's Your Anxiety</strong>. 
				</p>
				
				<div style="background: rgba(255,255,255,0.03); padding: 24px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.1); margin-bottom: 40px; text-align: center;">
					<p style="margin: 0; font-size: 15px; color: #f8fafc; line-height: 1.5;">
						<strong>Important:</strong> Please keep this email safe. You will use the <strong>same email and password</strong> you just created to log in once the app officially drops on the App Store.
					</p>
				</div>
				
				<p style="font-size: 18px; line-height: 1.6; color: #94a3b8; margin-bottom: 40px; text-align: center;">
					Our clinical therapy labs and aura intelligence are ready for you. Click the button below to join the TestFlight beta and download the app immediately.
				</p>
				
				<div style="text-align: center; margin-bottom: 50px;">
					<a href="https://testflight.apple.com/join/pPTtSX2v" class="button" style="display: inline-block; background: #0071e3; color: white; padding: 20px 40px; border-radius: 16px; text-decoration: none; font-weight: 700; font-size: 20px; box-shadow: 0 15px 30px rgba(0,113,227,0.4);">Download Beta on TestFlight</a>
				</div>
				
				<div style="text-align: center;">
					<a href="https://whatsyouranxiety.com" style="color: #475569; text-decoration: none; font-size: 14px; font-weight: 600;">whatsyouranxiety.com</a>
				</div>
				
				<p style="font-size: 12px; color: #334155; margin-top: 60px; text-align: center; letter-spacing: 1px; text-transform: uppercase;">
					&copy; 2026 What's Your Anxiety. Built with ❤️ for your mind.
				</p>
			</div>
		</body>
		</html>
	`;

	try {
		const response = await fetch("https://api.resend.com/emails", {
			method: "POST",
			headers: {
				"Authorization": `Bearer ${env.RESEND_API_KEY}`,
				"Content-Type": "application/json",
			},
			body: JSON.stringify({
				from: "What's Your Anxiety <welcome@whatsyouranxiety.com>",
				to: [email],
				subject: "Welcome to the WYA 3.0 Beta!",
				html: html,
			}),
		});

		if (response.ok) {
			console.log("Welcome email sent successfully via Resend to:", email);
		} else {
			const err = await response.text();
			console.error("Resend Error:", response.status, err);
		}
	} catch (e) {
		console.error("Failed to send welcome email:", e);
	}
}

function jsonResponse(body: unknown, status = 200): Response {
	return new Response(JSON.stringify(body), {
		status,
		headers: {
			"Content-Type": "application/json",
			"Access-Control-Allow-Origin": "*",
		},
	});
}

function errorResponse(message: string, status: number): Response {
	return jsonResponse({ error: message }, status);
}

// Basic JWT-like token generation (Simple for MVP, use a library for production)
async function generateToken(userId: string, secret: string): Promise<string> {
	const header = btoa(JSON.stringify({ alg: "HS256", typ: "JWT" }));
	const payload = btoa(JSON.stringify({ sub: userId, iat: Math.floor(Date.now() / 1000) }));
	
	const msg = new TextEncoder().encode(`${header}.${payload}`);
	const key = await crypto.subtle.importKey(
		"raw",
		new TextEncoder().encode(secret),
		{ name: "HMAC", hash: "SHA-256" },
		false,
		["sign"]
	);
	const sig = await crypto.subtle.sign("HMAC", key, msg);
	const sigBase64 = btoa(String.fromCharCode(...new Uint8Array(sig)))
		.replace(/\+/g, "-")
		.replace(/\//g, "_")
		.replace(/=/g, "");

	return `${header}.${payload}.${sigBase64}`;
}

async function verifyToken(token: string, secret: string): Promise<string | null> {
	try {
		const [header, payload, sig] = token.split(".");
		const msg = new TextEncoder().encode(`${header}.${payload}`);
		
		const key = await crypto.subtle.importKey(
			"raw",
			new TextEncoder().encode(secret),
			{ name: "HMAC", hash: "SHA-256" },
			false,
			["verify"]
		);
		
		const sigData = new Uint8Array(
			atob(sig.replace(/-/g, "+").replace(/_/g, "/"))
				.split("")
				.map((c) => c.charCodeAt(0))
		);
		
		const isValid = await crypto.subtle.verify("HMAC", key, sigData, msg);
		if (!isValid) return null;
		
		const decodedPayload = JSON.parse(atob(payload));
		return decodedPayload.sub;
	} catch {
		return null;
	}
}

async function hashPassword(password: string): Promise<string> {
	const msgUint8 = new TextEncoder().encode(password);
	const hashBuffer = await crypto.subtle.digest("SHA-256", msgUint8);
	const hashArray = Array.from(new Uint8Array(hashBuffer));
	return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

// ---------- route handlers ----------

async function handleSignUp(request: Request, env: Env): Promise<Response> {
	const { email, password, name } = await request.json() as any;
	if (!email || !password) return errorResponse("Email and password required.", 400);

	const passwordHash = await hashPassword(password);
	const userId = crypto.randomUUID();

	try {
		await env.DB.prepare(
			"INSERT INTO users (id, email, password_hash, display_name) VALUES (?, ?, ?, ?)"
		)
			.bind(userId, email, passwordHash, name)
			.run();
		
		const token = await generateToken(userId, env.JWT_SECRET);
		
		// Send welcome email asynchronously (don't block the response)
		sendWelcomeEmail(email, name, env);

		return jsonResponse({ userId, token, name });
	} catch (e: any) {
		if (e.message.includes("UNIQUE")) return errorResponse("Email already in use.", 409);
		return errorResponse("Signup failed.", 500);
	}
}

async function handleLogin(request: Request, env: Env): Promise<Response> {
	const { email, password } = await request.json() as any;
	const passwordHash = await hashPassword(password);

	const user = await env.DB.prepare(
		"SELECT id, display_name FROM users WHERE email = ? AND password_hash = ?"
	)
		.bind(email, passwordHash)
		.first<any>();

	if (!user) return errorResponse("Invalid email or password.", 401);

	const token = await generateToken(user.id, env.JWT_SECRET);
	return jsonResponse({ userId: user.id, token, name: user.display_name });
}

async function handleGetUserData(userId: string, env: Env): Promise<Response> {
	const row = await env.DB.prepare(
		"SELECT data_json, updated_at FROM user_data WHERE user_id = ?"
	)
		.bind(userId)
		.first<{ data_json: string; updated_at: string }>();

	if (!row) return errorResponse("No data found.", 404);

	return jsonResponse({
		userId,
		data: JSON.parse(row.data_json),
		updatedAt: row.updated_at,
	});
}

async function handlePutUserData(userId: string, request: Request, env: Env): Promise<Response> {
	const body = await request.json();
	const dataJson = JSON.stringify(body);
	const now = new Date().toISOString();

	await env.DB.prepare(
		`INSERT INTO user_data (user_id, data_json, updated_at)
		 VALUES (?, ?, ?)
		 ON CONFLICT(user_id) DO UPDATE SET data_json = excluded.data_json, updated_at = excluded.updated_at`
	)
		.bind(userId, dataJson, now)
		.run();

	return jsonResponse({ userId, updatedAt: now });
}

// ---------- router ----------

export default {
	async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
		if (request.method === "OPTIONS") {
			return new Response(null, {
				headers: {
					"Access-Control-Allow-Origin": "*",
					"Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
					"Access-Control-Allow-Headers": "Content-Type, Authorization",
				},
			});
		}

		const url = new URL(request.url);
		const path = url.pathname;

		// Health
		if (path === "/api/v1/health") return jsonResponse({ status: "ok" });

		// Auth
		if (path === "/api/v1/auth/signup" && request.method === "POST") {
			const { email, password, name } = await request.json() as any;
			if (!email || !password) return errorResponse("Email and password required.", 400);

			const passwordHash = await hashPassword(password);
			const userId = crypto.randomUUID();

			try {
				await env.DB.prepare(
					"INSERT INTO users (id, email, password_hash, display_name) VALUES (?, ?, ?, ?)"
				)
					.bind(userId, email, passwordHash, name)
					.run();
				
				const token = await generateToken(userId, env.JWT_SECRET);
				
				// Ensure the email is sent before the worker shuts down
				ctx.waitUntil(sendWelcomeEmail(email, name, env));

				return jsonResponse({ userId, token, name });
			} catch (e: any) {
				if (e.message.includes("UNIQUE")) return errorResponse("Email already in use.", 409);
				return errorResponse("Signup failed.", 500);
			}
		}
		
		if (path === "/api/v1/auth/login" && request.method === "POST") return handleLogin(request, env);

		// Authorized routes
		const authHeader = request.headers.get("Authorization") ?? "";
		const token = authHeader.replace(/^Bearer\s+/i, "");
		
		let userId = await verifyToken(token, env.JWT_SECRET);
		
		// Fallback to master API_SECRET for dev/testing
		if (!userId && token === env.API_SECRET) {
			const masterMatch = path.match(/^\/api\/v1\/users\/([a-zA-Z0-9_-]+)\/data$/);
			if (masterMatch) userId = masterMatch[1];
		}

		if (!userId) return errorResponse("Unauthorized.", 401);

		// Data routes
		if (path === `/api/v1/users/${userId}/data`) {
			if (request.method === "GET") return handleGetUserData(userId, env);
			if (request.method === "PUT") return handlePutUserData(userId, request, env);
		}

		return errorResponse("Not found.", 404);
	},
};
