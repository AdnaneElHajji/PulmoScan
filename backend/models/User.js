const pool = require("../db"); // connexion PostgreSQL
const bcrypt = require("bcrypt");

const User = {
  async create({ nom, email, password }) {
    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      "INSERT INTO users (nom, email, password) VALUES ($1, $2, $3) RETURNING *",
      [nom, email, hashedPassword]
    );

    return result.rows[0];
  },

  async findByEmail(email) {
    const result = await pool.query(
      "SELECT * FROM users WHERE email = $1",
      [email]
    );
    return result.rows[0];
  }
};

module.exports = User;
