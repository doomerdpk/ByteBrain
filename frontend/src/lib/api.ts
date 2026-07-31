import axios from "axios";

export const api = axios.create({
  baseURL: "/api/v1/",
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");

  if (
    token &&
    !config.url?.includes("/login") &&
    !config.url?.includes("/signup") &&
    !config.url?.includes("/brain/:hash")
  ) {
    config.headers.Authorization = `Bearer ${token}`;
  }

  return config;
});
