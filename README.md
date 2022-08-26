# HTML Table to Excel parser + Telegram Notification bot

## Overview
- This code was written to monitor SIEMENS SIMATIC S7 CPU variable tables accessed through http.
- The html table is refreshed periodically to extract data and send status updates of the laboratory via Telegram to Smartphones.
- This includes Plots and Webcam images.
- Read the description in the header of [main.m](main.m) to understand the logic + tutorial for generation of Telegram Bot.
- There is a full [Matlab Telegram API][TgramApi] for bidirectional communication, but it seemed like overkill for this task.
- This is not a "proper (or general) implementation" but may be useful for you if you face a similar problem.
- Webcam access requires Webcam Toolbox / Vision Toolbox, Telegram and HTML Table parsing only requires vanilla Matlab license.

## Disclaimer

- Code is provided "as is".

[TgramApi]: <https://github.com/alekseikukin/mtbtapi>
