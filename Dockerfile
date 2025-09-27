FROM node:20-alpine AS base

# Install necessary packages for the setup script
RUN apk add --no-cache \
    bash \
    curl \
    git \
    tar

WORKDIR /app

# Copy the setup script and make it executable
COPY setup_docker.sh .
RUN chmod +x setup_docker.sh

# Copy package files first for better layer caching
COPY package.json package-lock.json* bun.lock* ./

# Install bun directly (more reliable for Docker)
RUN curl -fsSL https://bun.sh/install | bash && \
    echo 'export BUN_INSTALL="$HOME/.bun"' >> /etc/profile && \
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> /etc/profile

# Set environment variables for bun
ENV BUN_INSTALL=/root/.bun
ENV PATH="$BUN_INSTALL/bin:$PATH"

# Run the setup script to install dependencies
# This will now skip bun installation since it's already installed
RUN ./setup_docker.sh

# Copy the rest of the application code
COPY . .

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S ritmex -u 1001

# Change ownership of the app directory and copy bun installation to user home
USER root
RUN chown -R ritmex:nodejs /app && \
    cp -r /root/.bun /home/ritmex/ && \
    chown -R ritmex:nodejs /home/ritmex/.bun

# Set PATH for the non-root user
USER ritmex
ENV BUN_INSTALL=/home/ritmex/.bun
ENV PATH="$BUN_INSTALL/bin:$PATH"

# Expose any ports if needed (uncomment if your app needs a port)
# EXPOSE 3000

# Set the entrypoint to run the application
ENTRYPOINT ["bun", "start"]

# Default command (can be overridden with docker run args)
CMD []