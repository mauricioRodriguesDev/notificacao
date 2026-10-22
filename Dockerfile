FROM gradle:9-jdk17-corretto AS build
WORKDIR /app
COPY . .
RUN gradle build --no-daemon


FROM amazoncorretto:17-alpine-jdk

WORKDIR /app
COPY --from=build /app/build/libs/*.jar /app/notificacao.jar
EXPOSE 8082
CMD ["java", "-jar", "/app/notificacao.jar"]