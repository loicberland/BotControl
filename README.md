# BotControl

Addon WoW 2.4.3 pour piloter un groupe de bots via une interface simple.

## Structure rapide

- `BotControl.lua`
  Gère l'interface, les onglets, les sous-onglets, les boutons, les tooltips et le layout.
- `BotControl_Actions.lua`
  Gère la logique des actions et les commandes envoyées.
- `BotControl_Config.lua`
  Gère la configuration sauvegardée.
- `BotControl.xml`
  Déclare la frame principale et quelques éléments de base.

## Onglets Actions

L'onglet `Actions` est séparé en deux sous-onglets :

- `Config`
- `Combat`

Les groupes d'éléments sont gérés dans `BotControl.lua` :

- `BotControl_ActionElements`
- `BotControl_ActionConfigElements`
- `BotControl_ActionCombatElements`

## Ajouter un nouveau bouton d'action

Cette section explique comment ajouter manuellement un nouveau bouton dans un sous-onglet `Actions`.

Exemple :

- nom interne : `MyNewAction`
- sous-onglet : `Combat`
- tooltip titre : `Mon action`
- tooltip description : `Lance une commande de test`

### 1. Ajouter la config visuelle du bouton

Fichier :

- [BotControl.lua](c:/Users/berla/Qsync/Dev/AddonWOW/BotControl/BotControl.lua)

Zone à modifier :

- table `BotControl.ACTION_BUTTON_CONFIG`

Ajouter une entrée :

```lua
MyNewAction = {
    texture = "Interface\\Icons\\INV_Misc_QuestionMark",
    title = "Mon action",
    description = "Lance une commande de test"
}
```

Cette entrée sert pour :

- l'icône
- le tooltip
- le style uniforme avec les autres boutons

### 2. Créer le bouton dans l'UI

Fichier :

- [BotControl.lua](c:/Users/berla/Qsync/Dev/AddonWOW/BotControl/BotControl.lua)

Zone à modifier :

- fonction `BotControl.CreateButtons(frame)`

Il faut :

1. ajouter une variable locale en haut de la fonction
2. créer le bouton avec `CreateFrame(...)`
3. brancher son `OnClick`

Exemple :

```lua
local myNewActionButton
```

Puis dans la fonction :

```lua
if not BotControlMyNewActionButton then
    myNewActionButton = CreateFrame("Button", "BotControlMyNewActionButton", frame, "UIPanelButtonTemplate")
    myNewActionButton:SetText("My action")
    myNewActionButton:SetWidth(110)
    myNewActionButton:SetHeight(24)
    myNewActionButton:SetScript("OnClick", function()
        BotControl_RunNamedAction("MyNewAction")
    end)
end
```

Le texte affiché ici n'est pas important visuellement, car le bouton sera ensuite stylé en icône.

### 3. Appliquer le style icône + tooltip

Fichier :

- [BotControl.lua](c:/Users/berla/Qsync/Dev/AddonWOW/BotControl/BotControl.lua)

Zone à modifier :

- fonction `BotControl.StyleActionButtons()`

Ajouter :

```lua
config = BotControl.ACTION_BUTTON_CONFIG.MyNewAction
BotControl_SetActionButtonIcon(BotControlMyNewActionButton, config.texture, config.title, config.description)
```

### 4. Enregistrer le bouton dans les bons groupes

Fichier :

- [BotControl.lua](c:/Users/berla/Qsync/Dev/AddonWOW/BotControl/BotControl.lua)

Zone à modifier :

- fonction `BotControl.RegisterTabElements(frame)`

Toujours ajouter le bouton dans :

- `BotControl_ActionElements`

Puis l'ajouter dans le bon sous-groupe :

- `BotControl_ActionConfigElements` si le bouton doit apparaître dans `Config`
- `BotControl_ActionCombatElements` si le bouton doit apparaître dans `Combat`

Exemple pour `Combat` :

```lua
BotControl.AddElement(BotControl_ActionElements, BotControlMyNewActionButton)
BotControl.AddElement(BotControl_ActionCombatElements, BotControlMyNewActionButton)
```

Exemple pour `Config` :

```lua
BotControl.AddElement(BotControl_ActionElements, BotControlMyNewActionButton)
BotControl.AddElement(BotControl_ActionConfigElements, BotControlMyNewActionButton)
```

Important :

- si tu oublies `BotControl_ActionElements`, le bouton risque de ne pas suivre correctement l'affichage global de l'onglet `Actions`
- si tu oublies le sous-groupe `Config` ou `Combat`, le bouton ne s'affichera pas dans le bon sous-onglet

### 5. Positionner le bouton dans le layout

Fichier :

- [BotControl.lua](c:/Users/berla/Qsync/Dev/AddonWOW/BotControl/BotControl.lua)

Zone à modifier :

- fonction `BotControl_LayoutButtons()`

Il faut :

1. récupérer le bouton en variable locale
2. le placer dans le bloc `Config` ou `Combat`

Exemple :

```lua
local myNewActionButton = BotControlMyNewActionButton
```

Puis dans le bloc du sous-onglet voulu :

```lua
if myNewActionButton then
    myNewActionButton:ClearAllPoints()
    myNewActionButton:SetPoint("LEFT", usedButton, "RIGHT", iconSpacing, 0)
end
```

Conseil :

- pour `Config`, place-le dans la grille après le dernier bouton de config
- pour `Combat`, place-le dans la grille après le dernier bouton de combat

### 6. Ajouter la logique de l'action

Fichier :

- [BotControl_Actions.lua](c:/Users/berla/Qsync/Dev/AddonWOW/BotControl/BotControl_Actions.lua)

#### a. Déclarer l'action

Dans `BotControlActions.definitions`, ajouter :

```lua
MyNewAction = {
    label = "My new action",
    builder = "MyNewActionCommands"
}
```

#### b. Créer la fonction qui construit les commandes

Exemple simple :

```lua
function BotControlActions:MyNewActionCommands()
    local commands = {}

    AddParty(commands, "follow")

    return commands
end
```

Helpers déjà disponibles :

- `AddWhisper(commands, target, message)`
- `AddParty(commands, message)`
- `AddSlash(commands, command)`

#### c. Créer la fonction bouton si nécessaire

Pour rester cohérent avec le reste du fichier :

```lua
function BotControl_Action_MyNewAction()
    if BotControlActions and BotControlActions.RunAction then
        BotControlActions:RunAction("MyNewAction")
    end
end
```

### 7. Brancher l'action dans le dispatcher UI

Fichier :

- [BotControl.lua](c:/Users/berla/Qsync/Dev/AddonWOW/BotControl/BotControl.lua)

Zone à modifier :

- fonction `BotControl_RunNamedAction(actionName)`

Pour une action standard, il y a deux façons de faire.

#### Cas simple

Tu peux laisser le `else` final appeler automatiquement :

```lua
BotControlActions:RunAction(actionName)
```

Dans ce cas, si ton bouton appelle `BotControl_RunNamedAction("MyNewAction")`, ça fonctionnera sans ajouter de branche spéciale, tant que :

- l'entrée existe dans `BotControlActions.definitions`
- la fonction `MyNewActionCommands()` existe

#### Cas spécial

Ajoute une branche spécifique seulement si tu as un comportement particulier.

Exemple :

- envoi en file d'attente
- enchaînement spécial
- logique custom non standard

### 8. Resize automatique

Le resize des sous-onglets `Actions` dépend actuellement du nombre d'éléments dans :

- `BotControl_ActionConfigElements`
- `BotControl_ActionCombatElements`

Le calcul est fait dans :

- `BotControl_UpdateFrameSizeForView(mainTab, subTab)` dans [BotControl.lua](c:/Users/berla/Qsync/Dev/AddonWOW/BotControl/BotControl.lua)

Donc, en pratique :

- si tu ajoutes correctement ton bouton au bon groupe, le resize suivra automatiquement

### 9. Cas spécial : action en file d'attente

Aujourd'hui, `Init Bots` est un cas particulier.

Pourquoi :

- cette action envoie beaucoup de commandes slash d'affilée
- elle utilise une exécution temporisée pour éviter que la dernière commande reste coincée dans le chat

Fichiers concernés :

- [BotControl_Actions.lua](c:/Users/berla/Qsync/Dev/AddonWOW/BotControl/BotControl_Actions.lua)
- [BotControl.lua](c:/Users/berla/Qsync/Dev/AddonWOW/BotControl/BotControl.lua)

Fonctions utiles :

- `BotControl.RunCommands(commands)`
- `BotControl.RunCommandsQueued(commands)`

Règle simple :

- action normale : utiliser `RunAction(...)` et le flux standard
- action lourde avec beaucoup de slashs : utiliser éventuellement `RunCommandsQueued(...)`

## Résumé ultra court

Pour ajouter un bouton d'action, il faut penser à ces endroits :

1. `BotControl.lua`
   Ajouter l'entrée dans `ACTION_BUTTON_CONFIG`
2. `BotControl.lua`
   Créer le bouton dans `BotControl.CreateButtons(frame)`
3. `BotControl.lua`
   Le styliser dans `BotControl.StyleActionButtons()`
4. `BotControl.lua`
   L'ajouter dans `BotControl_ActionElements`
5. `BotControl.lua`
   L'ajouter dans `BotControl_ActionConfigElements` ou `BotControl_ActionCombatElements`
6. `BotControl.lua`
   Le positionner dans `BotControl_LayoutButtons()`
7. `BotControl_Actions.lua`
   Ajouter l'entrée dans `BotControlActions.definitions`
8. `BotControl_Actions.lua`
   Ajouter la fonction `...Commands()`
9. `BotControl.lua`
   Vérifier si `BotControl_RunNamedAction()` a besoin d'un cas spécial

## Exemple minimal complet

Si tu veux ajouter un bouton `Dance` dans `Combat` :

- `BotControl.lua`
  Ajouter `Dance` dans `ACTION_BUTTON_CONFIG`
- `BotControl.lua`
  Créer `BotControlDanceButton`
- `BotControl.lua`
  L'ajouter dans `StyleActionButtons()`
- `BotControl.lua`
  L'ajouter dans `BotControl_ActionElements`
- `BotControl.lua`
  L'ajouter dans `BotControl_ActionCombatElements`
- `BotControl.lua`
  Le placer dans la grille `Combat`
- `BotControl_Actions.lua`
  Ajouter :

```lua
Dance = {
    label = "Dance",
    builder = "DanceCommands"
}
```

- `BotControl_Actions.lua`
  Ajouter :

```lua
function BotControlActions:DanceCommands()
    local commands = {}

    AddParty(commands, "dance")

    return commands
end
```

Dans ce cas, pas besoin de modifier `BotControl_RunNamedAction()` si tu restes sur le flux standard.
