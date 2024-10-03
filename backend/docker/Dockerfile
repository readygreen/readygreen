# Stage 1: Build
FROM gradle:8.8-jdk17 as build

WORKDIR /app
COPY ./build.gradle build.gradle
COPY ./settings.gradle settings.gradle
COPY ./src/main src/main

# Build the application
RUN gradle clean bootJar --no-daemon

# Stage 2: Package
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the built JAR from the build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Entrypoint
ENTRYPOINT ["java", "-Duser.timezone=Asia/Seoul", "-jar", "/app/app.jar"]
EXPOSE 8080

