# Multi-stage build para Quarkus
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

COPY --from=build /app/target/quarkus-app /app

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/quarkus-run.jar"]
