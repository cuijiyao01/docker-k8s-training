# compile stage with name "builder"
FROM maven:3.6.3 as builder
COPY . /usr/src/build
WORKDIR /usr/src/build
RUN mvn verify

# run stage
FROM openjdk:8-jdk-alpine
COPY --from=builder /usr/src/build/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar"]
