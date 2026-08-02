module.exports = {
  apps: [
    {
      name: "bytebrain-backend",
      cwd: "/opt/bytebrain/app/backend",
      script: "dist/index.js",
      instances: 2,
      exec_mode: "cluster",
      env: {
        NODE_ENV: "production",
      },
      max_memory_restart: "300M",
      error_file: "/var/log/bytebrain/backend-error.log",
      out_file: "/var/log/bytebrain/backend-out.log",
      log_date_format: "YYYY-MM-DD HH:mm:ss",
    },
  ],
};