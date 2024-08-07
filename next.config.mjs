/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: "https", // or http
        hostname: "https://github.com/LivingInUK/sunnybay", // if your website has no www, drop it
      },
    ],
  },
};

export default nextConfig;
