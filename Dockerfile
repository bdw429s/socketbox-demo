# Stage 1: Use foundeo/minibox to perform the build steps
FROM foundeo/minibox AS builder

# Set the working directory to /app
WORKDIR /app

# Copy the application code to the /app directory
COPY ./ /app

# Run the box install command
RUN box install

# Stage 2: Use ortussolutions/boxlang:miniserver as the final image
FROM ortussolutions/boxlang:miniserver-snapshot

# Set environment variable and expose port
ENV BOXLANG_PORT=10000
EXPOSE 10000

# Remove existing files in /app
RUN rm -r /app/*

# Copy the application code from the builder stage
COPY --from=builder /app /app
