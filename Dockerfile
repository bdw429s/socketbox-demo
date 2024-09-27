FROM ortussolutions/boxlang:miniserver-alpine
RUN rm /app/* -r 
ENV BOXLANG_PORT=10000
COPY ./ /app