# 1️⃣ Use Node.js LTS base image
FROM node:18

# 2️⃣ Set working directory in the container
WORKDIR /app

# 3️⃣ Copy package files first for better caching
COPY package*.json ./

# 4️⃣ Install dependencies
RUN npm install

# 5️⃣ Copy the rest of your app's code
COPY . .

# 6️⃣ Expose the port defined in your env file (default 3001)
EXPOSE 3001

# 7️⃣ Command to run the app
CMD ["node", "server.js"]
