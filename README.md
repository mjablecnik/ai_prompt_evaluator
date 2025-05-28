# ai_prompt_evaluator

A Dart CLI tool for automated evaluation of prompts using OpenAI's GPT-4. The tool reads prompts from a JSON file, queries GPT-4 for responses, auto-scores the responses (0–5), generates comments in Czech, saves the results as JSON, and creates a bar chart of the scores.

---

## Features

- Reads a list of prompts from a JSON file.
- Uses OpenAI's GPT-4 to generate responses for each prompt.
- Automatically scores each response (0–5) using GPT-4.
- Generates a Czech-language comment for each response.
- Saves results as a formatted JSON file.
- Generates a bar chart (PNG) of the scores using QuickChart.io.

---

## Requirements

- Dart SDK
- OpenAI API key (GPT-4 access)
- Internet connection (for OpenAI and QuickChart.io)

---

## Setup

1. **Clone the repository:**
   ```sh
   git clone https://github.com/mjablecnik/ai_prompt_evaluator.git
   cd ai_prompt_evaluator
   ```

2. **Install dependencies:**
   ```sh
   dart pub get
   ```

3. **Create a `.env` file in the project root with your OpenAI API key:**
   ```
   OPENAI_API_KEY=sk-...
   ```

---

## Usage

Run the evaluator from the project root:

```sh
dart lib/main.dart --input example/prompts.json --output example/results
```

- `--input` (`-i`): Path to the prompts JSON file (default: `prompts.json`)
- `--output` (`-o`): Directory to save results (default: `results`)

### Example prompts.json

```json
[
  "Jaký je hlavní město Francie?",
  "Napiš krátkou báseň o jaru."
]
```

### Output

- `evaluation.json`: List of objects with prompt, response, score, and comment.
- `graph.png`: Bar chart visualizing the scores for each prompt.

---

## Example Workflow

1. Prepare your prompts in a JSON file (see above).
2. Run the tool as shown in the Usage section.
3. Find the results and chart in the specified output directory.

---

## Dependencies

- [Dart](https://dart.dev/)
- [dio](https://pub.dev/packages/dio)
- [dotenv](https://pub.dev/packages/dotenv)
- [QuickChart.io](https://quickchart.io/) (for chart generation)
- [OpenAI API](https://platform.openai.com/)

---

## Author

👤 **Martin Jablečník**

- Website: [martin-jablecnik.cz](https://www.martin-jablecnik.cz)
- Github: [@mjablecnik](https://github.com/mjablecnik)
- Blog: [dev.to/mjablecnik](https://dev.to/mjablecnik)

---

## Show your support

Give a ⭐️ if this project helped you!

<a href="https://www.patreon.com/mjablecnik">
  <img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" width="160">
</a>

---

## 📝 License

Copyright © 2025 [Martin Jablečník](https://github.com/mjablecnik).
This project is [GNU GPLv3 License](https://choosealicense.com/licenses/gpl-3.0/) licensed.
