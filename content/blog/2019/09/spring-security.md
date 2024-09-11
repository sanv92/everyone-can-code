+++
author = "Sander"
categories = ["spring framework"]
tags = ["spring", "spring security", "framework"]
date = "2019-09-07"
description = "Short introduction to Spring Security Architecture"
featured = "spring-security.jpg"
featuredalt = "Short introduction to Spring Security Architecture"
featuredpath = "date"
linktitle = ""
title = "Short introduction to Spring Security Architecture"
type = "post"

+++

## Short introduction, how spring works step by step

### 1. Authentication Filter
{{< fancybox "date" "spring-security-authentication-filter-1.png" "A Spring Security Authentication Filter" "gallery" >}}

- Http Servlet Request
- Authentication Filter (Extract Username and Password from Header)
- Create Username and Password `"Authentication Token"` `"UsernamePasswordAuthenticationToken"`
- Pass `"Authentication Token"` to `"Authentication Manager"`

### 2. Authentication
{{< fancybox "date" "spring-security-authentication-token-2.png" "A Spring Security Authentication Filter" "gallery" >}}
After the system is successfully Authenticated the identity,
it will return new `"Authenticated Token"` with:

- Principal: UserDetails
- Credentials: (we no longer need to keep the password in our memory because it is not safe)
- Authorities: ROLE_USER
- Authenticated: true

Example: AbstractUserDetailsAuthenticationProvider
{{< highlight java >}}
protected Authentication createSuccessAuthentication(Object principal,
        Authentication authentication, UserDetails user) {
    UsernamePasswordAuthenticationToken result = new UsernamePasswordAuthenticationToken(
            principal, authentication.getCredentials(),
            authoritiesMapper.mapAuthorities(user.getAuthorities()));
    result.setDetails(authentication.getDetails());

    return result;
}
{{< /highlight >}}

UsernamePasswordAuthenticationToken
{{< highlight java >}}
public UsernamePasswordAuthenticationToken(Object principal, Object credentials,
        Collection<? extends GrantedAuthority> authorities) {
    super(authorities);
    this.principal = principal;
    this.credentials = credentials;
    super.setAuthenticated(true);
}
{{< /highlight >}}

### 3. AuthenticationProvider and UserDetails/Service
{{< fancybox "date" "spring-security-authentication-provider-3-and-user-details-service.png" "A Spring Security Authentication Filter" "gallery" >}}

`"Authentication Manager"` delegate `"Authenticated Token"` to `"Authentication Provider"`

#### More detailed:
ProviderManager is default implementation of interface Authentication Manager,
when we delegate providers to ProviderManager, it will check all providers, are they are supported or not,
it will only use those providers that are supported.

P.S: `"Authentication Manager"` is interface and `"ProviderManager"` is default implementation of this interface.

### 4. Security Context - it is holder for context information, related to security.
{{< fancybox "date" "spring-security-security-context-4.png" "A Spring Security Authentication Filter" "gallery" >}}

To access protected endpoints, you need to store `"Authentication Token"` that will be easily accessible,
that's where the `"ThreadLocal"` comes in, but we don't use it directly,
we use a higher level wrapper, `"Security Context"`.

To save `"Authentication Token"` some where, we use `"Security Context"` which allow us to stores a list of rules `"SecurityContext"` use `ThreadLocal<SecurityContext>` inside implementation.

`"ThreadLocal"` - allows us to store data that will be accessible only by a specific thread,
each thread holds it's own copy of data, as long as thread is alive.

### Authentication Recap
- "Authentication Filter" - creates and "Authentication Token" and passes it to the "Authentication Manager".
- "Authentication Manager" - delegates to the "Authentication Provider".
- "Authentication Provider" - uses a "UserDetailsService" to load the "UserDetails" and returns an "Authenticated Principal",
back to the "Authentication Manager".
- "Authentication Manager" - pass back to "Authentication Filter".
- "Authentication Filter" - sets the "Authentication Token" to the "SecurityContext".

### 5. Filter Security Interceptor - last filter in security filter chain, that protect access to protected resource
{{< fancybox "date" "spring-security-filter-security-interceptor-5.png" "A Spring Security Authentication Filter" "gallery" >}}
At the last stage, the authorization is based on the url of the request.
FilterSecurityInterceptor is inherited from AbstractSecurityInterceptor and decides, does current user has access to the current url.

### Authorization Recap
- FilterSecurityInterceptor obtains the "Security Metadata" by matching on the current request
- FilterSecurityInterceptor gets the current "Authentication"
- The "Authentication", "Security Metadata" and Request is passed to the "AccessDecisionManager"
- The "AccessDecisionManager" delegates to it's "AccessDecisionVoter(s)" for decision.

### 6. Access Decision
{{< fancybox "date" "spring-security-access-decision-6.png" "A Spring Security Authentication Filter" "gallery" >}}

### 7. Access Denied
{{< fancybox "date" "spring-security-access-denied-7.png" "A Spring Security Authentication Filter" "gallery" >}}
{{< fancybox "date" "spring-security-access-denied-7a.png" "A Spring Security Authentication Filter" "gallery" >}}
{{< fancybox "date" "spring-security-access-denied-7b.png" "A Spring Security Authentication Filter" "gallery" >}}
{{< fancybox "date" "spring-security-access-denied-7c.png" "A Spring Security Authentication Filter" "gallery" >}}

### Exception Handling Recap
- When "Access Denied" for current Authentication, the
ExceptionTranslationFilter delegates to the
AccessDeniedHandler, which by default, returns a 403
Status.

- When current Authentication is "Anonymous", the
ExceptionTranslationFilter delegates to the
AuthenticationEntryPoint to start the Authentication
process.

---

#### Books:
- https://drive.google.com/open?id=14O1lUgbu1spklLraPUBTQTX0fZN72670

#### More detailed articles:
- https://habr.com/ru/post/346628/
- https://spring.io/guides/topicals/spring-security-architecture/
- https://www.baeldung.com/java-threadlocal
- https://docs.oracle.com/javase/7/docs/api/java/lang/ThreadLocal.html
- https://drive.google.com/file/d/1uiOKOxSI33AxW4EXpzXwbj0z77zJk0Ev/view
- https://docs.spring.io/spring-security/site/docs/5.2.x/reference/htmlsingle/#filter-ordering
- https://gist.github.com/zmts/802dc9c3510d79fd40f9dc38a12bccfc

#### Other articles:
- http://it-uroki.ru/uroki/bezopasnost/identifikaciya-autentifikaciya-avtorizaciya.html
- https://auth0.com/blog/implementing-jwt-authentication-on-spring-boot/

#### More detailed videos:
- https://www.youtube.com/watch?v=8rnOsF3RVQc
- https://www.youtube.com/watch?v=dAUTSfdGyLU
