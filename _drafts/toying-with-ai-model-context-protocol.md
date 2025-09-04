---
layout: post
title: 'Toying with AI: Model Context Protocol'
tags:
- chatgpt
- openai
- ai
- llm
- python
- mcp
---

[Model Context Protocol](https://modelcontextprotocol.io/) or MCP, is quickly
being adopted as a standard for extending Large Language Model (LLM) based AI
functionality. But what is it? By the end of this post I hope to have
explained the main concepts of MCP and have built a simple Dice Rolling MCP
Server.

At a high level, MCP is an open protocol that tries to standardise the way you
can add capabilities to your AI agents through
[tools](https://modelcontextprotocol.io/docs/learn/server-concepts#tools-ai-actions),
[prompts](https://modelcontextprotocol.io/docs/learn/server-concepts#prompts-interaction-templates),
and
[resources](https://modelcontextprotocol.io/docs/learn/server-concepts#resources-context-data).
It also gives developers the ability for their tools to request the use of a
calling model through
[sampling](https://modelcontextprotocol.io/docs/learn/client-concepts#sampling)
and ask users for access to specific information via
[elicitation](https://modelcontextprotocol.io/docs/learn/client-concepts#elicitation).

In their own words:

> MCP is an open protocol that standardizes how applications provide context to
> large language models (LLMs). Think of MCP like a USB-C port for AI
> applications. Just as USB-C provides a standardized way to connect your
> devices to various peripherals and accessories, MCP provides a standardized
> way to connect AI models to different data sources and tools. MCP enables you
> to build agents and complex workflows on top of LLMs and connects your models
> with the world.

What does this all mean? Basically, MCP is a framework for building components
that work well with AI powered applications.

Let's learn more by building something. For this example, I am going to build
a simple dice server that can let LLMs roll dice using the notation that is
popular in tabletop role-playing games. I'll be using Python and
[FastMCP](https://gofastmcp.com) for this, but will try to explain things from
the MCP level. What's FastMCP? It's a Python framework for building MCP servers
and clients. Version 1.0 of FastMCP was actually incorporated in the official
MCP Python SDK in 2024. For this example I will be using FastMCP 2.0 which is
actively maintained. For a more in-depth guide on FastMCP, see their [Quickstart
page](https://gofastmcp.com/getting-started/quickstart).

I have a repo with the resulting dice server on
[GitHub](https://github.com/LyndonArmitage/dice-mcp).

## A Tool

At a high-level, I'd like to allow LLMs to roll dice and get random results.
While LLMs aren't normally deterministic (unless you crank the temperature
settings to 0), the randomness their internal models generate may be weighted
to certain outcomes and are largely opaque to us and time of use. So I'll need
to define a tool for them to use.

With MCP, tools are defined using [JSON Schema](https://json-schema.org/). This
makes them easy to validate, and more importantly easy to parse. This means
that tools like FastMCP have a known target to generate with their code. 

As an example, a really simple dice tool might look like this when using 
FastMCP:

```python
from fastmcp import FastMCP

mcp: FastMCP = FastMCP("Dice Roller")


@mcp.tool(
    name="roll",
    title="Roll Dice",
    description=(
        "Roll a dice based upon standard dice notation "
        "(e.g. 1d6, 2d20+1 etc.)"
    ),
)
def roll(notation: str = "1d6") -> str:
    # This is stub for now
    return "Rolled"


if __name__ == "__main__":
    mcp.run()
```

FastMCP likes to take advantage of [Pydantic](https://pydantic.dev/) and Python
[type hints](https://docs.python.org/3/library/typing.html) along with
annotations to make building MCP applications easy. In the above example you
can see a tool can be simply defined using an annotation on a function. In
fact, the example could be even simpler as all the fields on the `@mcp.tool
annotation are optional.

The above tool will be translated by FastMCP into JSON Schema and made
available when running.

An example of a more feature complete tool listing for a dice roller might look
like the following JSON Schema:

```json
{
  "tools": [
    {
      "name": "roll",
      "title": "Roll Dice",
      "description": "Roll a dice based upon standard dice notation (e.g. 1d6, 2d20+1 etc. see rules://dice for more info), with an optional seed number for the random number generator.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "notation": {
            "default": "1d6",
            "title": "Notation",
            "type": "string"
          },
          "seed": {
            "anyOf": [
              {
                "type": "integer"
              },
              {
                "type": "null"
              }
            ],
            "default": null,
            "title": "Seed"
          }
        }
      },
      "outputSchema": {
        "type": "object",
        "properties": {
          "notation": {
            "description": "The original dice notation, normalised.",
            "title": "Notation",
            "type": "string"
          },
          "result": {
            "description": "The result of the dice roll.",
            "title": "Result",
            "type": "integer"
          },
          "raw_total": {
            "description": "The result of all dice rolls added together without any modifiers applied.",
            "title": "Raw Total",
            "type": "integer"
          },
          "notation_explained": {
            "description": "The dice notation explained in text.",
            "title": "Notation Explained",
            "type": "string"
          },
          "roll_results": {
            "description": "The individual results of each roll.",
            "items": {
              "type": "integer"
            },
            "title": "Roll Results",
            "type": "array"
          }
        },
        "required": [
          "notation",
          "result",
          "raw_total",
          "notation_explained",
          "roll_results"
        ],
        "title": "RollResult"
      },
      "_meta": {
        "_fastmcp": {
          "tags": []
        }
      }
    }
  ]
}
```

This corresponds to a few more fields and a structured output in Python and
FastMCP:

```python
from typing import Optional

from pydantic import BaseModel, Field
from fastmcp import FastMCP

mcp: FastMCP = FastMCP("Dice Roller")


class RollResult(BaseModel):
    notation: str = Field(
        description="The original dice notation, normalised."
    )
    result: int = Field(description="The result of the dice roll.")
    raw_total: int = Field(
        description=(
            "The result of all dice rolls added together without any "
            "modifiers applied."
        )
    )
    notation_explained: str = Field(
        description="The dice notation explained in text."
    )
    roll_results: list[int] = Field(
        description="The individual results of each roll."
    )


@mcp.tool(
    name="roll",
    title="Roll Dice",
    description=(
        "Roll a dice based upon standard dice notation "
        "(e.g. 1d6, 2d20+1 etc. see rules://dice for more info), "
        "with an optional seed number for the random number "
        "generator."
    ),
)
def roll(
    notation: str = "1d6", 
    seed: Optional[int] = None
) -> RollResult:
    # This is a stub
    pass

```

As you can see, the JSON Schema is quite large compared to the FastMCP
definition, but both encode the same information.

With this tool defined, an LLM could now choose to invoke it if it supports
MCP. Of course you'd need to be running the MCP server somewhere. Luckily for
us, MCP standardises the [transport
layers](https://modelcontextprotocol.io/docs/learn/architecture#transport-layer)
it supports.

We have the choice of standard input/output streams (STDIO) for direct process
communication on a local machine, or Streamable HTTP transport to allow for
access across machines. Both layers make use of the same message format for
communication. Again this standardisation means the people implementing MCP
have a non-ambiguous target to aim for, and it ensures MCP servers and clients
of all different types can interoperate.

By default, FastMCP's `mcp.run()` will use STDIO. This suits us well for the 
dice server, since we aren't providing a dice rolling service to the internet.

## Resources

You may have noticed that I reference a resource in the more complete tool
code. Resources are context data that your MCP server can make available to an
LLM. They could expose fixed data, data from files, APIs, Databases, or any
other data source that might be needed for context.

Resources use URIs, with each having a unique URI. For example:

```python
@mcp.resource(
    "rules://dice",
    name="rules",
    title="Dice Rules",
    description="Reference rules for dice notation.",
    mime_type="text/markdown",
)
def dice_rules() -> str:
    return """
Dice notation takes the form XdYoZ:
- X = number of dice (default 1 if omitted)
- Y = sides per die (minimum 2)
- o = optional operation to do to the result
- Z = optional modifier, used by the operation
Examples:
  - `d20` roll one 20-sided die
  - `3d6+2` roll three six-sided dice and add 2
  - `1d10` roll one 10-sided die
  - `36d12-10` roll 36 12-sided dice and subtract 10 from the total

Supported operations are:
 - Addition with +
 - Subtraction with -
""".strip()
```

Above defines a resource with the URI `rules://dice`. It returns some markdown
describing what dice notation looks like.

The information in resources can be given to LLMs for context, but it is up to
the application talking to the LLM to decide to do this. Some AI code assistant
tools for instance, will let you reference resources and have them
automatically pasted into the LLM context.

MCP also allows for dynamic resources via resource templates. For example, we
could write a resource template that can take a given dice notation and explain
what it means:

```python
@mcp.resource(
    "explain://{dice_notation}",
    name="explain_notation",
    title="Explain Dice Notation",
    description="Explains the given dice notation in text",
    mime_type="text/plain",
)
def explain_notation(dice_notation: str) -> str:
    roll = parse_notation(dice_notation)
    return roll.as_text()
```

This would allow you to use a URI like `explain://4d6` to get context into what
`4d6` means. In this example it might return "Roll 4 6 sided dice."

## Prompts

Prompts in MCP are essentially interaction templates. They give an example of a
query to an LLM that should make use of the tools and resources provided. They
are entirely user triggered and not automatically used by applications.

With FastMCP, you can define multiple messages that comprise a prompt, and even
reference resources. For example, the following passes in the context from the
`rules://dice` and adds a simple prompt template:

```python
@mcp.prompt(
    title="How to use dice notation",
    description="Get information on how to use dice notation.",
)
async def dice_help(example: str = "2d6+2", ctx: Context = None) -> list[dict]:
    result = await ctx.read_resource("rules://dice")
    result_content = types.TextResourceContents(
        uri="rules://dice", mimeType="text/markdown", text=str(result[0].content)
    )

    embedded = types.EmbeddedResource(type="resource", resource=result_content)

    message = (
        "Explain how to write dice notation and give a few examples. "
        f"Include what '{example}' means. "
        "Reference rules://dice if needed."
    )
    return [
        PromptMessage(role="user", content=embedded),
        PromptMessage(
            role="user", 
            content=TextContent(type="text", text=message)
        ),
    ]
```

The main benefit of prompts is that they can show developers how the MCP server
is expected to be used, and expose simple ready-made workflows.

## A Dice MCP Server

With tools, resources and prompts explained, we now have a simple [dice
server](https://github.com/LyndonArmitage/dice-mcp). Using my full repository,
I can run `uv run fastmcp run main.py:mcp` and then hook up the MCP server to
an application that supports it and I'll have access to the features
implemented.

## MCP Client Concepts

Model Context Protocol doesn't just define server based concepts, it also
allows you to build
[client](https://modelcontextprotocol.io/docs/learn/client-concepts)
interactions. Unfortunately, I haven't explored these as well as the server
focussed concepts but we can look at them in brief.

Sampling allows servers to request a language model perform a completion for
them. This means that you can build agentic behaviours within your MCP servers
without having to provide your own LLM to users. Of course, MCP clients don't
just blindly let servers use their language models whenever they like. Sampling
is gated with a request to the user, preventing chatty MCP servers from racking
up large bills.

Roots allow you to express file boundaries to an MCP server. Ultimately, the
MCP client is responsible for asking the user's permission on accessing files,
but roots are used to provide guidance to the MCP server.

Elicitation allows your MCP servers to request specific information from the
user during interactions in a structured way. It means servers can pause their
operations and wait for a specific piece of information is given, and handle it
if it is not volunteered. This also means that you don't have to front-load all
the information in a single request.

## That's it

With those client concepts briefly explained that's it. That is the basics of
Model Context Protocol, MCP explained with an example.
