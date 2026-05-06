require("dotenv").config();
const express = require("express");
const cors = require("cors");
const fetch = require("node-fetch");
const Groq = require("groq-sdk").default;
const { GoogleGenerativeAI } = require("@google/generative-ai");

const app = express();
const PORT = process.env.PORT || 5000;

app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type"],
  }),
);
app.options("*", cors());
app.use(express.json());
app.get("/api", async (req, res) => {
  const response = await fetch(
    `https://api.cloudflare.com/client/v4/accounts/59205764eb86e1959dc3b4804db8f9ef/ai/run/@cf/meta/llama-3.1-8b-instruct`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer 59205764eb86e1959dc3b4804db8f9ef`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        messages: [{ role: "user", content: "Hello" }],
      }),
    },
  );
  const result = await response.json();
  console.log(result);
});

app.listen(PORT, () =>
  console.log(`✅ AEO Diagnostic running on port ${PORT} — 6 AI models`),
);
