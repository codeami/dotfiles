# Ingestion rules (Layer 3)

How new sources (transcripts, talks, videos) enter the brain.

## Unique ID (required)

Every transcript capture in inbox/ gets a unique ID:

    <creator>-<keyword>-<YYYY-MM-DD>

- creator: the author, lowercased, hyphenated (kun-chen, van-clief).
- keyword: a short slug of the content (l8-agentic-workflow, second-brain-talk).
- date: the video / publish date in ISO form; if unknown, use "undated" until confirmed.

Examples:

- kun-l8-agentic-workflow-2026-06-20.md
- kun-l8-fullstack-app-2026-07-27.md
- kun-second-brain-talk-undated.md

## Flow

1. 01-capture: write inbox/<unique-id>.md (the short signal file; never the full raw).
2. 02-distill: each atomic idea becomes nodes/<slug>.md; its source line cites the unique ID.
3. 03-connect: add the note to shared/index.md.

## Rules

- The unique ID is the stable link between a transcript and the notes distilled from it.
- Notes cite source as "Author, 'Title' (<unique-id>)" so evidence traces to a dated origin.
- Never commit the full raw transcript; keep the signal file plus the source link.
