const express = require('express');

const app = express();
const port = process.env.PORT || 3000;
const environment = process.env.ENVIRONMENT || 'local';
const appSecretAvailable = process.env.APP_SECRET_JSON ? 'yes' : 'no';
const dbHost = process.env.DB_HOST || 'not-set';

app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok', environment });
});

app.get('/', (_req, res) => {
  res
    .status(200)
    .send(`
      <html>
        <head><title>PagerDuty CSG Demo</title></head>
        <body style="font-family: Arial; padding: 2rem;">
          <h1>Hello, World!</h1>
          <p>This app is running on ECS Fargate.</p>
          <ul>
            <li><strong>Environment:</strong> ${environment}</li>
            <li><strong>DB Host:</strong> ${dbHost}</li>
            <li><strong>Secrets loaded:</strong> ${appSecretAvailable}</li>
          </ul>
        </body>
      </html>
    `);
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
