Class InstructionPrompts : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $prompts = Get-InstructionPromptNames
        return ($prompts.Keys | Sort-Object)
    }
}

$script:instructionPromptPath = [System.Collections.Generic.HashSet[string]]::new()
$script:instructionPromptPath += "$PSScriptRoot\InstructionPrompts"
<#
.SYNOPSIS
    Weaves instructions into a prompt.

.DESCRIPTION
    The Weave function is used to weave instructions into a prompt. It takes user input and processes it based on the specified instructions.

.PARAMETER Instructions
    Specifies the set of instructions to use for weaving. Valid values are obtained from the Get-InstructionPromptNames function.

.PARAMETER UserInput
    Specifies the user input to be processed. This parameter accepts input from the pipeline.

.SWITCHPARAMETER Chat
    Indicates whether to enable chat mode. This feature is not yet implemented.

.SWITCHPARAMETER ListPrompts
    Indicates whether to list all available instruction prompts.

.INPUTS
    System.Object

.OUTPUTS
    System.Object

.EXAMPLE
    "arm templates, bicep, ansible, terraform" | Weave CompareAndContrast

|           | Arm Templates | Bicep | Ansible | Terraform |
|-----------|---------------|-------|---------|-----------|
| Language  | JSON          | Bicep | YAML    | HCL       |
| Complexity| High          | Low   | Medium  | Medium    |
| Provisioning| Yes         | Yes   | Yes     | Yes       |
| Configuration Management| No | No   | Yes     | No       |
| Cloud Compatibility| Azure | Azure | Multi-Cloud | Multi-Cloud   |
| Community Support| Good   | Growing| Strong   | Strong    |
| Learning Curve| Steep | Moderate | Moderate | Moderate  |

.EXAMPLE
    Weave -ListPrompt

    This example lists all available instruction prompts.
#>
function Weave {
    [CmdletBinding()]
    param(
        [ValidateSet([InstructionPrompts])]
        $Instructions,
        [Parameter(ValueFromPipeline)]
        $UserInput,
        [Switch]$ListPrompt,
        [Switch]$Chat
    )

    Process { $lines += @($UserInput) } 

    End {
        if ($ListPrompt) {
            (Get-InstructionPromptNames).Keys | Sort-Object
            return
        }

        $instructionsFile = (Get-InstructionPromptNames)[$instructions]
        $instructionPrompt = Get-Content $instructionsFile -Raw

        if ($Chat) {
            'Not yet implemented, coming soon...'
        }
        else {
            $instructionPrompt = $ExecutionContext.InvokeCommand.ExpandString($instructionPrompt)
            Write-Verbose $instructionPrompt
            $lines | Invoke-OAIChat $instructionPrompt
        }
    }
} 

<#
.SYNOPSIS
Retrieves the names and full paths of instruction prompt files.

.DESCRIPTION
The Get-InstructionPromptNames function retrieves the names and full paths of instruction prompt files located in the script's instructionPromptPath directory. It returns an ordered hashtable where the keys are the base names of the files and the values are their corresponding full paths.

.PARAMETER None
This function does not accept any parameters.

.EXAMPLE
Get-InstructionPromptNames

This example demonstrates how to use the Get-InstructionPromptNames function to retrieve the names and full paths of instruction prompt files.

.OUTPUTS
System.Collections.Specialized.OrderedDictionary
The function returns an ordered hashtable where the keys are the base names of the instruction prompt files and the values are their corresponding full paths.

#>
function Get-InstructionPromptNames {
    [CmdletBinding()]
    $map = [Ordered]@{}
    Get-ChildItem $script:instructionPromptPath | ForEach-Object { 
        $map[$_.BaseName] = $_.FullName
    }
    $map
}

<#
.SYNOPSIS
Adds a path to the instruction prompt path.

.DESCRIPTION
The Add-PromptPath function adds a specified path to the instruction prompt path. 
The instruction prompt path is a collection of paths that are used by the instruction prompt to search for executable files.

.PARAMETER Path
Specifies the path to be added to the instruction prompt path.

.EXAMPLE
Add-PromptPath -Path "C:\Program Files\MyApp"

This example adds "C:\Program Files\MyApp" to the instruction prompt path.
#>
function Add-PromptPath {
    [CmdletBinding()]
    param(
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        Write-Error "Path $Path does not exist"
        return
    }

    $Path = (Resolve-Path $Path).Path
    $script:instructionPromptPath += @($Path)
}