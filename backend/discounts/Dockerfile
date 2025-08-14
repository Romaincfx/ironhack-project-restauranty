# 1️⃣ Use Node.js LTS image
FROM node:18

# 2️⃣ Set working directory
WORKDIR /app

# 3️⃣ Copy package files for dependency install
COPY package*.json ./

# 4️⃣ Install dependencies
RUN npm install

# 5️⃣ Copy the rest of the code
COPY . .

# 6️⃣ Expose the service port
# If you have PORT in your .env (e.g., PORT=3002), it will be mapped at runtime.
EXPOSE 3002

# 7️⃣ Start the app
# Replace 'server.js' if your actual entry file is different (e.g., index.js)
CMD ["node", "server.js"]
