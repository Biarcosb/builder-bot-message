module.exports = {
    apps: [
      {
        name: "notificador_wpp",
        script: "dist/app.js", // Asegúrate de que este sea el punto de entrada correcto
        instances: 1, // Cambiar a "max" si deseas usar todos los núcleos disponibles
        autorestart: true,
        watch: false,
        max_memory_restart: "512M",
        env: {
          NODE_ENV: "production",
          PORT: process.env.PORT || 3008,
        },
        cron_restart: "0 */6 * * *", // Reinicia cada 6 horas
      },
    ],
  };
  