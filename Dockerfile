# Multi-stage build for Spring Boot application
FROM maven:3.8.4-openjdk-17 AS build

# Set working directory
WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Runtime stage
FROM openjdk:17-jre-slim

# Create app user
RUN groupadd -r bookshop && useradd -r -g bookshop bookshop

# Set working directory
WORKDIR /app

# Copy the built JAR from build stage
COPY --from=build /app/target/bookshop-backend-*.jar app.jar

# Create uploads directory
RUN mkdir -p uploads && chown -R bookshop:bookshop uploads

# Switch to non-root user
USER bookshop

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
