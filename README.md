# Illinois Early Termination Tool

A bilingual (English and Spanish) web tool from REFORM Alliance that helps people on mandatory supervised release or parole in Illinois see where they stand in the officer's 6-month review and the Prisoner Review Board's decision. It is not for people on probation.

**Live app:** address not recorded here yet (see [Publish](#publish)).

Part of REFORM Alliance's early termination tools: [Georgia](https://github.com/REFORM-Alliance/georgia-early-termination-tool) · [Florida](https://github.com/REFORM-Alliance/florida-early-termination-tool) · **Illinois** · [Virginia](https://github.com/REFORM-Alliance/va-implementation-tool) · [Pennsylvania Act 44](https://github.com/REFORM-Alliance/act-44-flow-chart-app).

## What it tells people

- **Officer review:** the supervision officer must review the case at least every 6 months and give a written report within 30 days, listing the steps still required if early termination is not recommended.
- **Board decision:** the Prisoner Review Board decides whatever the officer recommends. After the required steps are completed, the person may apply to the Board, which must decide within 30 days.
- **Loop:** a denied application returns the person to the Board's list of steps until they are complete and they can apply again.
- **Under 6 months served:** the Board may terminate at any time but is unlikely to before 6 months.

## How the flow works

The tool is a scripted question-and-answer flow. A person answers one screen at a time, their answers choose the next screen, and a result screen says what they can do. Screens are numbered in the order a person meets them; each screen's code ID is its `question_id` in `app.R` (listed below the diagram).

```mermaid
flowchart TD
  S1["S1 Welcome"]
  S2["S2 On supervised release or parole?"]
  S3(["S3 Result: tool is not for probation"])
  S4["S4 Supervised at least 6 months?"]
  S6["S6 Received the officer's written report?"]
  S5(["S5 Result: Board may act any time"])
  S7(["S7 Result: report is legally required"])
  S8["S8 Report recommended early termination?"]
  S10["S10 Officer's steps completed?"]
  S9["S9 Board approved the recommendation?"]
  S11["S11 Board's steps completed?"]
  S12["S12 Board approved the application?"]
  S13(["S13 Result: Board unlikely until steps done"])
  S14(["S14 Result: supervision terminated early"])
  S1 --> S2
  S2 -->|"Yes"| S4
  S2 -->|"No"| S3
  S4 -->|"Yes"| S6
  S4 -->|"No"| S5
  S6 -->|"Yes"| S8
  S6 -->|"No"| S7
  S8 -->|"Yes"| S9
  S8 -->|"No"| S10
  S10 -->|"Yes"| S12
  S10 -->|"No"| S13
  S9 -->|"Yes"| S14
  S9 -->|"No"| S11
  S11 -->|"Yes"| S12
  S11 -->|"No"| S13
  S12 -->|"Yes"| S14
  S12 -->|"No"| S11
  classDef result fill:#eef6ee,stroke:#3d7a3d
  class S3,S5,S7,S13,S14 result
```

Rounded boxes are result screens. Every question is a single Yes/No. S11 and S12 form a loop.

<details>
<summary>Screen numbers and code IDs</summary>

| Screen | `question_id` |
| --- | --- |
| S1 | `intro_page` |
| S2 | `initial_question` |
| S3 | `ineligible_response` |
| S4 | `supervision_length_question` |
| S5 | `pre-6_month_response` |
| S6 | `written_report_question` |
| S7 | `early_termination_result_1` |
| S8 | `early_termination_question` |
| S9 | `board_approval_question` |
| S10 | `steps_and_requirements_question` |
| S11 | `steps_and_requirements_question2` |
| S12 | `board_approval_question2` |
| S13 | `steps_and_requirements_result` |
| S14 | `successful_early_termination_result` |

</details>

## Repository layout

| File or folder | What it is |
| --- | --- |
| `app.R` | The whole app: packages, the `decision_tree` list (every screen and its routing), page layout and server logic. |
| `json/translation.json` | English-to-Spanish text pairs. The English text is the lookup key. |
| `www/reform-logo-charcoal.png` | The logo at the top of the page. Shiny serves everything in `www/` as-is. |
| `renv.lock`, `renv/`, `.Rprofile` | Pinned package versions. `.Rprofile` switches renv on when the project opens. |
| `manifest.json` | The R version and package list that Posit Connect Cloud builds the app from. Regenerate it with `rsconnect::writeManifest()` after any package change. |
| `illinois-early-termination-tool.Rproj` | The RStudio project file. The app finds `json/translation.json` relative to it. |

The pinned versions are R 4.5.0 with the packages in `renv.lock`. The app loads `shiny`, `tidyverse`, `shinythemes`, `shinyWidgets`, `shinyjs`, `shinyalert`, `shiny.i18n`, `lubridate`, `scales`, `here`, `rsconnect` and `googleLanguageR`. The last two are loaded but never called, so no Google or hosting credentials are needed to run it.

## Run it locally

1. Install R 4.5.0 and the RStudio desktop app.
2. Clone or download this repo and double-click `illinois-early-termination-tool.Rproj`. RStudio opens the project and renv switches on by itself.
3. In the R console, run `renv::restore()` once. It installs the pinned package versions.
4. Open `app.R` and click **Run App**, or run `shiny::runApp()` in the console.
5. Switch the language picker to Spanish and click through every route you changed.

## Edit wording, questions and Spanish

- Each screen is one block in the `decision_tree` list at the top of `app.R`: `question_id` (its name), `question` or `result` (the text), `choices` (the answer buttons) and `next_question` (where each answer leads).
- After changing any English text, make the matching change to the `"en"` value in `json/translation.json` and rewrite its `"es"` value. Matching is exact, including punctuation and curly quotes, and text is translated in pieces around links and bold words. A miss shows that piece in English and logs a warning.
- Screen names must be unique and every name in `next_question` must exist, or Next does nothing. Keep the first screen as the welcome screen.
- Link to a statute with `tags$a(href='URL', target='_blank', class='external-link', "text")`. The `external-link` class triggers the "Leaving Application" confirmation.
- English and Spanish are written into the picker and the answer-lookup code in several places, so a third language needs code changes as well as a new column.

## Publish

This tool is hosted on [Posit Connect Cloud](https://connect.posit.cloud). Connect Cloud copies the code from the GitHub repository and builds the app itself, so publishing an update means getting the change onto the GitHub branch that Connect Cloud follows (normally `main`; **Settings > Source** in Connect Cloud shows which). Nothing is uploaded from your computer. Connect Cloud addresses have the form `https://<account>-<custom name>.share.connect.posit.cloud`. The early termination tools' addresses of that form begin with `bfs6`, the name of the Connect Cloud account that owns them.

**Live address not recorded.** The address for this tool has not been added to this README yet. Once it is confirmed, add it to the **Live app** line and the table at the end.

### Publish an update

1. Make and test the change on your computer (see **Run it locally**).
2. If you added or upgraded an R package, run `renv::snapshot()` and then `rsconnect::writeManifest()` in the R console, and commit both `renv.lock` and `manifest.json`. Connect Cloud reads `manifest.json` for the package list, so a stale one gives the live app the wrong packages or fails the build.
3. Commit and push to `main` (RStudio's Git tab, GitHub Desktop or the command line all work), or merge a pull request into it. "Automatically publish on push" is on by default, so Connect Cloud rebuilds and redeploys the app. The address does not change.
4. Open the live address, switch the language picker to Spanish and click through the routes you changed.
5. If the live app did not change, sign in to Connect Cloud, open the app's card on your Home page and look at the publish log for an error. **Republish** on the card redeploys from the latest code on GitHub.

### Publish for the first time, or re-create the app

1. In the project folder, run `rsconnect::writeManifest()` in the R console. Commit and push `app.R`, `manifest.json`, `json/` and `www/`.
2. Sign in to [Connect Cloud](https://connect.posit.cloud) with the account that owns this app.
3. Click **Publish** at the top of your Home page. The first time, Connect Cloud asks you to install its GitHub App; give it access to this repository. A repo owned by the REFORM-Alliance organization may need an organization owner to approve the app.
4. Choose **Shiny**, then select this repository.
5. Confirm the **Branch** is `main` and the **Primary file** is `app.R`. Leave **Automatically publish on push** on.
6. Click **Publish** and watch the build log. When it finishes, the app is live at an address like `https://<content id>.share.connect.posit.cloud`.
7. Open the app's **Settings > URL** to choose the address people will use.
8. Open the address in a private browser window to check that someone who is not signed in to Connect Cloud can use it.

### If something goes wrong

- **The repository is missing from the Publish list.** Connect Cloud's GitHub App does not have access to it. Give the app access in GitHub, then reload the list. Automatic publishing also only works for repositories the app can reach.
- **Free accounts can publish only public repositories.** If this repository is ever made private, the Connect Cloud account needs a paid plan.
- **The build fails after a package change.** Run `rsconnect::writeManifest()` again, commit `manifest.json` and push.
- **No secrets to set.** `app.R` reads no environment variables, so nothing is needed under Advanced settings.

## Known issues

Found by reading the code; the app was not run. Confirm each before changing anything.

- S12 names the "Parole Review Board" where every other screen says Prisoner Review Board.
- S13 says the Board may terminate your "probation" although the tool covers supervised release and parole.
- S5 says the Board reviews every 6 months; S6 and S7 say the supervision officer does. Confirm which is correct.
- The statute links point to the Illinois General Assembly pages for 730 ILCS 5/3-14-2 and 5/3-3-8, but the screens do not print the citations.

## Keep the sibling repos in step

The five early termination tools copy the same engine rather than sharing a package. A fix to how the app behaves, as opposed to what it says, should be repeated in the other repos.

| Tool | Repository | Live app |
| --- | --- | --- |
| Georgia | [georgia-early-termination-tool](https://github.com/REFORM-Alliance/georgia-early-termination-tool) | <https://bfs6-georgia-early-termination-tool.share.connect.posit.cloud/> |
| Florida | [florida-early-termination-tool](https://github.com/REFORM-Alliance/florida-early-termination-tool) | <https://bfs6-florida-early-termination-tool.share.connect.posit.cloud/> |
| Illinois | [illinois-early-termination-tool](https://github.com/REFORM-Alliance/illinois-early-termination-tool) | not recorded yet |
| Virginia | [va-implementation-tool](https://github.com/REFORM-Alliance/va-implementation-tool) | <https://www.reformvaearlyterminationtool.com/> |
| Pennsylvania Act 44 | [act-44-flow-chart-app](https://github.com/REFORM-Alliance/act-44-flow-chart-app) | <https://bfs6-act-44-early-termination-tool.share.connect.posit.cloud/> |