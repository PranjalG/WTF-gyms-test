require("dotenv").config();
const express = require("express");
const jwt = require("jsonwebtoken");
const { v4: uuidv4 } = require("uuid");

const app = express();
app.use(express.json());

const APP_ACCESS_KEY = process.env.HMS_APP_ACCESS_KEY;
const APP_SECRET = process.env.HMS_APP_SECRET;
const PORT = process.env.PORT || 3000;

if (!APP_ACCESS_KEY || !APP_SECRET) {
  console.error("❌ Missing HMS_APP_ACCESS_KEY or HMS_APP_SECRET in .env");
  process.exit(1);
}

/**
 * GET /token?userId=DK&role=member&roomId=optional
 * Returns a signed 100ms auth token for the given user + role.
 */
app.get("/token", (req, res) => {
  const { userId, role, roomId } = req.query;

  if (!userId || !role) {
    return res.status(400).json({
      error: "Missing required params: userId and role",
    });
  }

  const validRoles = ["host", "guest"];
  if (!validRoles.includes(role)) {
    return res.status(400).json({
      error: `Invalid role. Must be one of: ${validRoles.join(", ")}`,
    });
  }

  try {
    const payload = {
      access_key: APP_ACCESS_KEY,
      room_id: roomId || "*",         // '*' = any room; pass specific roomId when joining
      user_id: userId,
      role: role,
      type: "app",
      version: 2,
      iat: Math.floor(Date.now() / 1000),
      nbf: Math.floor(Date.now() / 1000),
      jti: uuidv4(),
    };

    const token = jwt.sign(payload, APP_SECRET, {
      algorithm: "HS256",
      expiresIn: "24h",
    });

    console.log(`[TOKEN] Generated for userId=${userId} role=${role} roomId=${roomId || "*"}`);

    return res.json({ token });
  } catch (err) {
    console.error("[TOKEN] Error generating token:", err.message);
    return res.status(500).json({ error: "Token generation failed" });
  }
});

/**
 * POST /rooms
 * Creates a new 100ms room dynamically using a Management Token.
 */
app.post("/rooms", async (req, res) => {
  try {
    // Generate management token signed with APP_SECRET and APP_ACCESS_KEY
    const payload = {
      access_key: APP_ACCESS_KEY,
      type: "management",
      version: 2,
      iat: Math.floor(Date.now() / 1000),
      nbf: Math.floor(Date.now() / 1000),
      jti: uuidv4(),
    };

    const managementToken = jwt.sign(payload, APP_SECRET, {
      algorithm: "HS256",
      expiresIn: "24h",
    });

    const response = await fetch("https://api.100ms.live/v2/rooms", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${managementToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name: `room-${uuidv4()}`,
        description: "WTF Gyms Call Room",
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error("[ROOM] Failed to create 100ms room:", errText);
      return res.status(response.status).json({
        error: "Failed to create 100ms room",
        details: errText,
      });
    }

    const roomData = await response.json();
    console.log(`[ROOM] Created 100ms room with ID: ${roomData.id}`);
    return res.json({ roomId: roomData.id });
  } catch (err) {
    console.error("[ROOM] Error creating room:", err.message);
    return res.status(500).json({ error: "Room creation failed" });
  }
});


// Health check
app.get("/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`✅ WTF Token Server running on http://localhost:${PORT}`);
  console.log(`   GET /token?userId=DK&role=guest`);
  console.log(`   GET /token?userId=Aarav&role=host`);
//  console.log(`   GET /health`);
});
