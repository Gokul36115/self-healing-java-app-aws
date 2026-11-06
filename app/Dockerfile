# ---------- Stage 1: BUILD the JAR ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn -q clean package -DskipTests

# ---------- Stage 2: RUN the app (small image) ----------
FROM eclipse-temurin:17-jre
WORKDIR /app

# curl is needed for the health check below
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Run as a non-root user (security best practice)
RUN useradd -r -s /bin/false appuser
COPY --from=build /build/target/*.jar app.jar
RUN chown appuser /app/app.jar
USER appuser

EXPOSE 8080

# Docker checks app health every 15s
HEALTHCHECK --interval=15s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-XX:+ExitOnOutOfMemoryError", "-jar", "app.jar"]