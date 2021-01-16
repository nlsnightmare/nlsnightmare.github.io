---
layout: post
title: PUT, file upload and Laravel
tags:
  - php
  - javascript
---
Hello! It's been a while. A quick post to start the year. See, a while back
we had a very weird bug: a `PUT` request would show up as empty in the backend,
and trigger a validation error. This was particularly weird, because we used the
exact same code, both backend and frontend, for another endpoint, and it worked fine.  

<!-- exerpt -->

## [Some Backstory](#some-backstory)
So, we have two endpoints. They accept the exact same request. [[1](#appendix-1)]
Let's call them `Endpoint A`, and `Endpoint B`.  
The only functional difference, is that `Endpoint A` accepts the `POST` request method, whereas `Endpoint B` accepts `PUT`.
Our frontend code looks like this:

```typescript
class SomeService {
    // constructors etc. emmited

    postThing(data: Thing): Observable {
        return this.http.post("/api/endpoint-a/", data.asFormData())
    }

    putThing(data: Thing): Observable {
        return this.http.put("/api/endpoint-b/", data.asFormData())
    }
}
```
Alright, so the code is really identical. There is no reason to believe that the result should be different.
But it is! Debugging things like this is very annoying, because it seems that it **must** work, yet it doesn't.


## [Digging Deeper](#digging-deeper)
Hey, wait a minute... what does this `asFormData` method do? Let's take a look

```typescript
class Thing {
    asFormData(): FormData {
        const data = new FormData()

        data.append('some-key', this.someKey)
        data.append('some-other-key', this.someOtherKey)

        // ... more appending to form data

        return data
    }
}
```
Ah, alright, it just created a `FormData` representation of the object. Is that necessary though?
Well yes! See, this `Thing` also contains files, specifically images. Since we want to upload the images
to our server, the most sensible thing to do is to convert it to `FormData`, since uploading files
using json is... inadvisable [[2](#appendix-2)]

## [The First Clue](#the-first-clue)
Now, since the endpoint doesn't really work, it's best to simplify it a little bit, and try to work out the details.
The only thing we can reasonably change id the whole `FormData` thing, so let's do that. We're sending simple json data now.

Oh hey, it works! Well, we can't send images anymore, but at least our request doesn't show up as empty. So why did 
`FormData` break it? Let's see if our friend, [stackoverflow.com](https://stackoverflow.com){:target="_blank"}, has something to say.

## [The Solution](#the-solution)
After a bit of googling [[3](#appendix-3)], this thread pops up: [https://stackoverflow.com/a/65009135](https://
stackoverflow.com/a/65009135){:target="_blank"}. Aha! Turns out the problem wasn't with my beloved Laravel after all. It's 
just php being php. PHP cannot process files in PUT requests... so does this mean that we can't upload our file?

Fear not, dear reader! For the great minds that built Laravel have this solved long, long ago. See, when you use
`blade templates` as your frontend, you usually do something like this:
```html
<form action="our-url" method="POST" >
    @method('PUT')

    <!-- inputs etc. -->
</form>
```
Right, since the http spec doesn't officialy support PUT requests, we fake them using the `@method('PUT')` directive.
All it does is inject this teeny-tiny bit of html to our form: 
```html
<input type="hidden" name="_method" value="PUT">
```
And internally laravel interprets POST requests which have the `_method` field set to `PUT` as `PUT` requests.
My god, does this mean that we can do this too? YES! In the end, the fix was this simple:
```typescript
putThing(data: Thing): Observable {
    const formData = data.asFormData()
    data.append('_method', 'PUT') // ADD THIS LINE!

    // ok, we also want to make this a post request
    return this.http.post("/api/endpoint-b/", data)
}
```
And it works! Another debugging session comes to it's end. If your team isn't familiar with the intricacies
of php, I'd *strongly suggest* you add a comment explaining the whole situation. Hey, you could even link this post,
right? ;)

## [Appendix](#appendix)
1. It may sound dump, but it's pretty common. Happens all the time when you have to be able to both create, as well as
update a given resource.
1. You techinally can, by endoding the image/whatever to `base64`, but you'd increase the payload size by roughly 33%.
This is definitely not worth it.
1. Because who the hell direcly searches on stackoverflow anyways?

