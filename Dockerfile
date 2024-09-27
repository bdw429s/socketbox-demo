FROM ortussolutions/boxlang:miniserver-alpine
RUN rm /app/* -r 
COPY ./ /app