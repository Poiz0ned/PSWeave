function CleanText {
    param(
        [Parameter(ValueFromPipeline)]
        $UserInput
    )

    Process { $lines += @($UserInput) }

    End {
        $instructions = @"
# IDENTITY and PURPOSE

You are an expert at cleaning up broken, misformatted, text, for example: line breaks in weird places, etc. 

# Steps

- Read the entire document and fully understand it.
- Remove any strange line breaks that disrupt formatting.
- Do NOT change any content or spelling whatsoever.

# OUTPUT INSTRUCTIONS

- Output the full, properly-formatted text.
- Do not output warnings or notes—just the requested sections.

# INPUT:

INPUT:

"@
        $lines | Invoke-OAIChat $instructions
    }
}
