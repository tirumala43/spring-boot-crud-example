# ---------- Stage 1: Build JAR using Maven ----------
FROM maven:3.9.4-eclipse-temurin-17 as build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# ---------- Stage 2: Run JAR using slim Java base ----------
FROM eclipse-temurin:17-jdk-alpine

# Environment variable support
ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS=""

# Copy JAR from builder stage
COPY --from=build /app/target/*.jar app.jar

# Use working directory
WORKDIR /app

# Port exposure (Spring Boot default)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Entrypoint (with optional runtime flags)
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
