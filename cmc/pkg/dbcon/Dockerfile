FROM maven:3.9.9-eclipse-temurin-17-focal AS build

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:17.0.14_7-jre-focal

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

ENV DB_URL=""
ENV DB_USER=""
ENV DB_PASSWORD=""

ENTRYPOINT ["java", "-jar", "app.jar"]
    