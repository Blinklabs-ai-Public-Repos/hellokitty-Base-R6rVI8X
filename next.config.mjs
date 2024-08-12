/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "assets.coingecko.com",
        port: "",
        pathname: "/**",
      },
      {
        protocol: "https",
        hostname: "i.seadn.io",
        port: "",
        pathname: "/**",
      },
      {
        protocol: "https",
        hostname: "ai-backend.dev.blinklabs.ai",
        port: "",
        pathname: "/**",
      },
      {
        protocol: "https",
        hostname: "ai-backend.blinklabs.ai",
        port: "",
        pathname: "/**",
      },
      {
        protocol: "https",
        hostname: "dep.infinitigenesis.com",
        port: "",
        pathname: "/**",
      },
      {
        protocol: "https",
        hostname: "prod.ai.api.infinitigenesis.com",
        port: "",
        pathname: "/**",
      },
    ],
  },
};

export default nextConfig;
