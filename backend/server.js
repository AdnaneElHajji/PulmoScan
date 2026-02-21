const express = require("express");
const cors = require("cors");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

const authRoutes = require("./routes/auth");
app.use("/api", authRoutes);

app.get("/", (req, res) => {
  res.send("PulmoScan API is running 🚀");
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});