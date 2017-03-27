# Slackin

This is small Elixir based slack bot that will allow employees to add time off to a virtual calendar and then anyone can ask the bot who's out to see a list of the people that have logged time out. 

This is currently in its first iteration so I expect there are quite a few bugs still.

## Getting Started

1. Clone this repo.

  ```
  git clone <REPO_URL>
  ```
2. Install Dependencies

  ```
  mix deps.get
  ```

3. Add a `<env>.secret.exs` file with your slack api key to the slackin config folder

  ```elixir
  use Mix.Config 

  config :slack, Slackin.Kin,
    secret_key: <YOUR_KEY_HERE>
  ```

4. Run from the command line

  ```
  mix run --no-halt
  ```

## Usage

> ALL DATES NEED TO BE IN THE FORMAT MM/DD/YYYY
> REASON FOR BEING OUT OF OFFICE NEEDS TO BE A SINGLE WORD (i.e. WFH, SICK, VACATION, etc)

Once it's running you should see the slackbot come online in your slack channel.

You can then invite @slackin to any channel you would like to use slackin from.

To add a time off for yourself: 

```
@slackin <FROM_DATE> <TO_DATE> <REASON>
```
Should receive response

```
@{username} Time off added!
```

To see who is in the office today just send a message with a question mark at the end:

```
@slackin <ANY TEXT HERE>?
```

If no one is out:
```
@<USER> Looks like we're all here today
```

If someone is out for the day:

```
@<PERSON OUT> is out for <REASON>
```

Contributing:

This was more of an elixir experiment so if you have ways to improve this please feel free to submit a pull request!