# BotControl

Addon WoW 2.4.3 pour piloter des bots via une interface simple.

Le but principal de ce README est d'expliquer comment ajouter, modifier et brancher un bouton d'action sans casser le reste.

## Structure rapide

- `BotControl.lua`
  Gere l'interface, les onglets, les sous-onglets, le layout, les boutons, les tooltips et l'execution des actions cote UI.
- `BotControl_Actions.lua`
  Gere la logique des actions et construit les commandes a executer.
- `BotControl_Config.lua`
  Gere la config sauvegardee.
- `BotControl.xml`
  Declare la frame principale et quelques elements de base.

## Etat actuel

### Onglet Profiles

L'onglet `Profiles` gere maintenant 3 formats :

- `5 joueurs`
- `10 joueurs`
- `25 joueurs`

Chaque format possede :

- ses propres profils sauvegardes
- son propre layout
- son propre jeu de slots actifs

Les slots utilisent tous la meme structure :

```lua
{
    name = "NomDuBot",
    role = "dps",
    class = "Mage",
    spec = "pve dps fire",
}
```

### Onglet Actions

L'onglet `Actions` est separe en 2 sous-onglets :

- `Config`
- `Combat`

Les groupes d'elements utilises par l'UI sont dans `BotControl.lua` :

- `BotControl_ActionElements`
- `BotControl_ActionSubTabElements`
- `BotControl_ActionConfigElements`
- `BotControl_ActionCombatElements`

### Actions actuellement en place

Sous-onglet `Config` :

- `ComposeGroup`
- `Build`
- `Init`
- `FullSetup`
- `Summon`
- `InitBots`

Sous-onglet `Combat` :

- `TankAttack`
- `AttackDPS`
- `Follow`
- `Passive`
- `Stay`
- `Used`

Les icones et tooltips de ces boutons sont decrits dans `BotControl.ACTION_BUTTON_CONFIG` dans `BotControl.lua`.

## Flux actuel d'une action

Quand on clique sur un bouton d'action ou qu'on tape une commande slash comme `/bc build` :

1. le bouton ou la slash command resolvent un nom d'action interne
2. `BotControl_RunNamedAction("ActionName")` est appele
3. sauf cas special, `BotControlActions:RunAction(actionName)` est appele
4. `BotControl_Actions.lua` cherche l'action dans `BotControlActions.definitions`
5. la fonction `...Commands()` correspondante construit une liste de commandes
6. `PrepareCommands()` developpe les variables de role si besoin
7. les commandes sont executees

Le point important : l'UI et les slash commands passent par le meme point d'entree.
Ajouter une commande `/bc ...` ne remplace donc pas le clic sur le bouton, c'est juste un complement.

## Commandes slash d'action

Le slash principal reste :

- `/bc`

Sans argument, il ouvre ou ferme l'interface.

Avec un argument, il tente d'executer une action :

- `/bc build`
- `/bc init`
- `/bc compose`
- `/bc summon`
- `/bc initbots`
- `/bc tankattack`
- `/bc attackdps`
- `/bc follow`
- `/bc passive`
- `/bc stay`
- `/bc used`

Tu peux aussi taper :

- `/bc help`

pour afficher la liste disponible en jeu.

La resolution des slash commands est geree dans `BotControl.lua` via :

- `BotControl.ACTION_COMMAND_ORDER`
- `BotControl.ACTION_COMMAND_ALIASES`
- `BotControl.SetupSlashCommands()`

Les variantes avec espaces, tirets ou underscores sont normalisees automatiquement.
Exemples :

- `/bc tank attack`
- `/bc tank-attack`
- `/bc tank_attack`

Ces trois formes pointent vers la meme action.

## Variables de role disponibles

Le moteur d'actions supporte maintenant :

- `{tank}`
- `{heal}`
- `{dps}`

Elles representent tous les bots du profil actif correspondant au role.

Exemple :

```text
/w {tank} stance tank
```

Si le profil actif contient `TankA` et `TankB` en role `tank`, l'action est developpee en :

```text
/w TankA stance tank
/w TankB stance tank
```

Cette expansion est faite dans `BotControl_Actions.lua` via `PrepareCommands()`.

## Ajouter un nouveau bouton d'action

Exemple :

- nom interne : `MyNewAction`
- sous-onglet : `Combat`
- titre tooltip : `Mon action`
- description tooltip : `Lance une commande de test`

### 1. Ajouter la config visuelle

Fichier :

- `BotControl.lua`

Zone :

- table `BotControl.ACTION_BUTTON_CONFIG`

Exemple :

```lua
MyNewAction = {
    texture = "Interface\\Icons\\INV_Misc_QuestionMark",
    title = "Mon action",
    description = "Lance une commande de test"
}
```

Cette entree sert pour :

- l'icone
- le tooltip
- le style uniforme

### 2. Creer le bouton dans l'UI

Fichier :

- `BotControl.lua`

Zone :

- fonction `BotControl.CreateButtons(frame)`

Il faut :

1. ajouter une variable locale au debut de la fonction
2. creer le bouton
3. brancher le `OnClick`

Exemple :

```lua
local myNewActionButton
```

Puis :

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

Le texte du bouton est peu important visuellement, car le bouton est ensuite transforme en bouton icone.

### 3. Appliquer le style icone + tooltip

Fichier :

- `BotControl.lua`

Zone :

- fonction `BotControl.StyleActionButtons()`

Ajouter :

```lua
config = BotControl.ACTION_BUTTON_CONFIG.MyNewAction
BotControl_SetActionButtonIcon(BotControlMyNewActionButton, config.texture, config.title, config.description)
```

### 4. Enregistrer le bouton dans les bons groupes

Fichier :

- `BotControl.lua`

Zone :

- fonction `BotControl.RegisterTabElements(frame)`

Toujours ajouter le bouton dans :

- `BotControl_ActionElements`

Puis l'ajouter dans le bon sous-groupe :

- `BotControl_ActionConfigElements` si le bouton doit apparaitre dans `Config`
- `BotControl_ActionCombatElements` si le bouton doit apparaitre dans `Combat`

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

- si tu oublies `BotControl_ActionElements`, le bouton ne suivra pas correctement l'affichage global de l'onglet `Actions`
- si tu oublies le sous-groupe `Config` ou `Combat`, il n'apparaitra pas dans le bon sous-onglet

### 5. Positionner le bouton dans le layout

Fichier :

- `BotControl.lua`

Zone :

- fonction `BotControl_LayoutButtons()`

Il faut :

1. recuperer le bouton dans une variable locale
2. le positionner dans le bloc `Config` ou `Combat`

Exemple :

```lua
local myNewActionButton = BotControlMyNewActionButton
```

Puis dans le bloc voulu :

```lua
if myNewActionButton then
    myNewActionButton:ClearAllPoints()
    myNewActionButton:SetPoint("LEFT", usedButton, "RIGHT", iconSpacing, 0)
end
```

Conseil :

- dans `Config`, place-le apres le dernier bouton `Config`
- dans `Combat`, place-le apres le dernier bouton `Combat`

### 6. Ajouter la logique de l'action

Fichier :

- `BotControl_Actions.lua`

#### a. Declarer l'action

Dans `BotControlActions.definitions`, ajouter :

```lua
MyNewAction = {
    label = "My new action",
    builder = "MyNewActionCommands"
}
```

#### b. Creer la fonction qui construit les commandes

Exemple simple :

```lua
function BotControlActions:MyNewActionCommands()
    local commands = {}

    AddParty(commands, "follow")

    return commands
end
```

Helpers deja disponibles :

- `AddWhisper(commands, target, message)`
- `AddParty(commands, message)`
- `AddSlash(commands, command)`

Si tu veux supporter les variables de role, tu peux ecrire directement des commandes avec :

- `{tank}`
- `{heal}`
- `{dps}`

Exemple :

```lua
function BotControlActions:MyNewActionCommands()
    local commands = {}

    AddSlash(commands, "/w {tank} stance tank")
    AddSlash(commands, "/w {heal} stay")

    return commands
end
```

`PrepareCommands()` se charge ensuite de dupliquer la commande pour chaque bot cible.

#### c. Creer une fonction speciale uniquement si besoin

Dans la plupart des cas, ce n'est pas necessaire.

Le flux standard suffit si :

- l'action existe dans `BotControlActions.definitions`
- la fonction `...Commands()` existe
- le bouton appelle `BotControl_RunNamedAction("MyNewAction")`

### 7. Faut-il modifier `BotControl_RunNamedAction()` ?

Fichier :

- `BotControl.lua`

Zone :

- fonction `BotControl_RunNamedAction(actionName)`

Regle actuelle :

- cas normal : ne rien ajouter, le `else` final appelle deja `BotControlActions:RunAction(actionName)`
- cas special : ajouter une branche seulement si le comportement doit etre different

Exemples de cas speciaux :

- envoi en file d'attente
- chainage particulier
- comportement non standard

### 7.b. Faut-il ajouter un alias slash ?

Si tu veux pouvoir appeler aussi l'action avec `/bc ...`, ajoute une entree dans :

- `BotControl.ACTION_COMMAND_ALIASES` dans `BotControl.lua`

Exemple :

```lua
MyNewAction = {
    "mynewaction"
}
```

Le premier alias sert de forme canonique pour l'aide affichee via `/bc help`.

Si tu n'ajoutes rien, la resolution essaiera quand meme le nom interne de l'action, mais ajouter un alias explicite est plus propre pour garder des commandes courtes et previsibles.

### 8. Resize automatique

Le resize des sous-onglets `Actions` depend du nombre d'elements dans :

- `BotControl_ActionConfigElements`
- `BotControl_ActionCombatElements`

Le calcul est fait dans :

- `BotControl_UpdateFrameSizeForView(mainTab, subTab)` dans `BotControl.lua`

Donc si tu ajoutes correctement ton bouton au bon groupe, le resize suivra automatiquement.

### 9. Cas special : action en file d'attente

`InitBots` est encore un cas particulier.

Pourquoi :

- cette action envoie beaucoup de commandes slash a la suite
- elle passe par `BotControl.RunCommandsQueued(...)`

Fonctions utiles :

- `BotControl.RunCommands(commands)`
- `BotControl.RunCommandsQueued(commands)`

Regle simple :

- action normale : flux standard via `RunAction(...)`
- action lourde avec beaucoup de slashs : utiliser eventuellement `RunCommandsQueued(...)`

## Modifier un bouton d'action existant

Pour modifier un bouton deja present, les points d'entree sont :

### Changer l'icone ou le tooltip

- `BotControl.ACTION_BUTTON_CONFIG` dans `BotControl.lua`

### Changer le sous-onglet d'affichage

- `BotControl.RegisterTabElements(frame)` dans `BotControl.lua`

Il faut le retirer d'un groupe et l'ajouter dans l'autre :

- `BotControl_ActionConfigElements`
- `BotControl_ActionCombatElements`

### Changer sa position

- `BotControl_LayoutButtons()` dans `BotControl.lua`

### Changer sa logique

- `BotControlActions.definitions` dans `BotControl_Actions.lua`
- la fonction `...Commands()` correspondante

### Changer un comportement special

- `BotControl_RunNamedAction()` dans `BotControl.lua`
- eventuellement la fonction wrapper correspondante dans `BotControl_Actions.lua`

## Resume ultra court

Pour ajouter un bouton d'action :

1. `BotControl.lua`
   Ajouter l'entree dans `ACTION_BUTTON_CONFIG`
2. `BotControl.lua`
   Creer le bouton dans `BotControl.CreateButtons(frame)`
3. `BotControl.lua`
   Le styliser dans `BotControl.StyleActionButtons()`
4. `BotControl.lua`
   L'ajouter dans `BotControl_ActionElements`
5. `BotControl.lua`
   L'ajouter dans `BotControl_ActionConfigElements` ou `BotControl_ActionCombatElements`
6. `BotControl.lua`
   Le positionner dans `BotControl_LayoutButtons()`
7. `BotControl_Actions.lua`
   Ajouter l'entree dans `BotControlActions.definitions`
8. `BotControl_Actions.lua`
   Ajouter la fonction `...Commands()`
9. `BotControl.lua`
   Verifier si `BotControl_RunNamedAction()` a besoin d'un cas special

## Exemple minimal complet

Si tu veux ajouter un bouton `Dance` dans `Combat` :

- `BotControl.lua`
  Ajouter `Dance` dans `ACTION_BUTTON_CONFIG`
- `BotControl.lua`
  Creer `BotControlDanceButton`
- `BotControl.lua`
  L'ajouter dans `StyleActionButtons()`
- `BotControl.lua`
  L'ajouter dans `BotControl_ActionElements`
- `BotControl.lua`
  L'ajouter dans `BotControl_ActionCombatElements`
- `BotControl.lua`
  Le placer dans le layout `Combat`
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
