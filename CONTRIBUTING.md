Hi!

Thanks for your contribution!

Sending a pull request is quite a simple process and for this you need to complete several steps.

Here's what to do:

1. Format your contribution according to the requirements.
2. Add the following checklist to the merge request description:

- [ ] Check the completed task in real conditions. (I have been verified.)
- [ ] Execution of the task. (I have been verified.)

3. Add an explanation about the change itself and why it's necessary.
4. There is the coding style, and there are the licensing requirements you need to comply with. A few examples:

- [Allman style][wiki.allman]

```code
while (x == y)
{
    something();
    somethingelse();
    // ...
    if (x < 0)
    {
        printf("Negative");
        negative(x);
    }
    else
    {
        printf("Non-negative");
        nonnegative(x);
    }
}

finalthing();
```

- Comment style [(Linus Torvalds)][lkml.torvalds]

```code
(a)
    /* This is a comment. */
(b)
    /*
    * This is also a comment, but it can now be cleanly
    * split over multiple lines
    */
(c)
    // This can be a single line. Or many. Your choice.
```

- Each variable should be on a new line. This makes it easier to document code.

```code
int a; // Your comment.
int b; // Your comment.
```

[wiki.allman]: https://en.wikipedia.org/wiki/Indentation_style#Allman_style
[lkml.torvalds]: https://lkml.org/lkml/2016/7/8/625

5. Send your contribution and wait for feedback.

# How do I get help if I'm stuck?

Firstly, don't get discouraged!

There are an enormous number of resources on the internet, and our developers who would like to see you succeed.

Many issues - especially about how to use certain tools - can be resolved by using your favourite internet search engine.

If you can't find an answer, there are a few places you can start:

    https://forum.ckcorp.ru - this website contains a lot of useful resources for new developers.
    https://wiki.ckcorp.ru/ - our wiki (open for contributions).

If you get really, really stuck, you could try to ask our teamleads: @root, @MonstrHW, @PRoSToC0der.
Please be aware that we have full-time jobs, so we are almost certainly the slowest way to get answers!

# I sent my pull request - now what?

Now you should wait for a review from our developers.

Our developers are generally very busy people, so it may take a few weeks before your patch is reviewed.

Then, you keep waiting.

1. Often these will be comments, which may require you to make changes to your patch, or explain why your way is the best way.
You should respond to these comments, and you may need to submit another revision of your patch to address the issues raised.

2. We're notoriously picky about how contributions are formatted and sent.

Your patch might be ignored.

> Happy hacking!