---
layout: post
title: Getting Burned by Mutabilty
tags:
  - php
---
Now, I know what you're thinking. Really, Nick? We all know that. Immutability is the way to go!
Well, yeah, but why? Without a real life example, the statement `everything must me immutable` can
be a tough pill to swallow.

<!-- excerpt -->

## [The hidden bug](#the-hidden-bug)
Today I was making a simple subscription api, when I noticed a very strange bug. The clients' subscriptions
never expired! Thankfully, this api hadn't launched yet, and the tests caught the bug anyways, but after
taking a look at the code, I was a bit confused. The `Subscription` class looked a bit like this:

```php
class Subscription
{
    private Carbon $start;
    private CarbonInterval $duration;

    // Constructor, setters etc. ommited

    public function getEnd(): bool
    {
        return $this->start->add($this->duration);
    }

    public function hasExpired(): bool
    {
        return now()->gt($this->getEnd());
    }
}
```

Nothing too crazy, right? Even if you've never written a single line of `php` in your life,
it should be pretty easy to understand. Now here's the failing test:

```php
$subscription = loadSubscriptionForClient($someClient);

// We 'time-travel' to one day after the subscription has ended
Carbon::setTestNow($subscription->getEnd()->addDay())

// Now the subscription must be expired, right? WRONG!
assertTrue($subscription->hasExpired());
```

Ok, what went wrong? Well, the title kinda gives it away, doesn't it? Theres a mutation going on!
...but there are no assigments. And that's the worst kind of mutation. The hidden mutation! *(pause for dramatic effect)*.

## [The hidden mutation](#the-hidden-mutation)
By now you've probably guessed it, but the hidden mutation is inside our `getEnd` function. So innocent looking,
yet so naughty. That's fine, I guess we should have read the documentation, right? It clearly states that:
> when you use a modifier on a Carbon instance, it modifies and returns the same instance

Great, just read the docs and remember when any function mutates the instance object, instead of creating a new one.
Doesn't sound that hard, right? ;) Oh, btw there are 2 mutations going on in the code. Wanna check what the second
one is?

## [The hidden mutation 2: Electric Boogaloo](#the-hidden-mutation-2-electric-boogaloo)
Hopefully, after all this reading, it's easy to spot. When we call `getEnd()->addDay()`, it adds one day to the
*start* property of our object! That can't be good. At least the fix is simple enough.


## [The fix](#the-fix)
Did you know that `php` has a `clone` keyword? Me neither, untill a few months ago. I'm not sure whether springling
our code with random `clone`s is a great idea though. Thankfully, `Carbon` has a nice `clone()` method, which solves the
problem... for now. However, in a situation like this, using actually immutable objects would have prevented the problem.
It looks like the `Carbon` team is one step ahead of me, since they also provide a `CarbonImmutable` class. If you value your sanity, and if you like **not** spending your time debugging problems like this, try to use it. Hopefully one day 
`Carbon` will be immutable by default.