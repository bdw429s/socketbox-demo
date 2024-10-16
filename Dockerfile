# Stage 1: Use foundeo/minibox to perform the build steps
FROM foundeo/minibox AS builder

# Set the working directory to /app
WORKDIR /app

# Copy the application code to the /app directory
COPY ./ /app

# Run the box install command
RUN box install

# Stage 2: Use ortussolutions/boxlang:miniserver as the final image
FROM ortussolutions/boxlang@sha256:841d5723f48faecdc0fe9075e861ce53824fafad2e9a51257659fbbcac9344bc

# Set environment variable and expose port
ENV BOXLANG_PORT=10000
ENV PORT=10000
EXPOSE 10000

# Remove existing files in /app
RUN rm -r /app/*

# Copy the application code from the builder stage
COPY --from=builder /app /app

RUN curl -o /usr/local/lib/boxlang-miniserver-1.0.0-snapshot-all.jar https://s3.amazonaws.com/downloads.ortussolutions.com/ortussolutions/boxlang-runtimes/boxlang-miniserver/1.0.0-snapshot/boxlang-miniserver-1.0.0-snapshot-all.jar

# Compile app
RUN  java -cp /usr/local/lib/boxlang-miniserver-1.0.0-snapshot-all.jar ortus.boxlang.compiler.BXCompiler --source /app --target /app --basePath /app

# RUN rm -rf /root/.boxlang/classes/

