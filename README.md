# BotControl

Addon WoW 2.4.3 pour piloter des bots via une interface simple.

## Structure

- `BotControl_ActionRegistry.lua`
  Registre central declaratif des actions.
- `BotControl_Actions.lua`
  Builders des commandes et execution des actions.
- `BotControl.lua`
  UI, slash commands, layout et generation des boutons.
- `BotControl_Config.lua`
  Stockage et chargement des profils.
- `BotControl.xml`
  Frame principale et quelques boutons XML historiques.

## Principe actuel

Les actions ne sont plus decrites a plusieurs endroits.

La source de verite est maintenant :

- `BotControl.ActionRegistry`

Chaque action declare en un seul bloc :

- sa cle interne
- son label
- son icone
- son tooltip
- son sous-onglet
- son groupe visuel
- son ordre
- ses alias slash
- son builder
- si elle doit etre queuee
- eventuellement une `sequence`

Exemple :

```lua
{
    key = "ComposeGroup",
    label = "Composer le groupe",
    tooltipTitle = "Composer le groupe",
    tooltipDescription = "Cree le groupe avec les bots configures",
    texture = "Interface\\Icons\\Spell_Nature_MassTeleport",
    tab = "Config",
    group = "Config",
    order = 10,
    aliases = { "compose" },
    builder = "ComposeGroupCommands",
    queued = false
}
```

## Ce qui est genere automatiquement

A partir du registre, l'addon reconstruit automatiquement :

- `BotControl.ACTION_BUTTON_CONFIG`
- `BotControl.ACTION_COMMAND_ORDER`
- `BotControl.ACTION_COMMAND_ALIASES`
- `BotControl.ACTION_BY_KEY`
- `BotControl.ACTIONS_BY_TAB`
- `BotControl.ACTIONS_BY_GROUP`

Le registre sert aussi a :

- resoudre les slash commands `/bc ...`
- construire l'aide `/bc help`
- creer les boutons d'action
- enregistrer les boutons dans les bons groupes UI
- positionner les boutons dans le layout
- executer les actions via `builder`, `queued` ou `sequence`

## Onglet Actions

Les sous-onglets existants restent :

- `Config`
- `Combat`

La presentation `Combat` conserve les groupes visuels :

- `Tank`
- `DPS`
- `Heal`
- `All`

Le layout est maintenant calcule a partir du registre :

- `Config` affiche les actions `tab = "Config"` triees par `order`
- `Combat` affiche les actions `tab = "Combat"` regroupees par `group`, puis triees par `order`

## Slash commands

Le slash principal reste :

- `/bc`

Sans argument :

- ouvre ou ferme l'interface

Avec un argument :

- execute une action declaree dans le registre

Exemples :

- `/bc build`
- `/bc init`
- `/bc compose`
- `/bc summon`
- `/bc initbots`
- `/bc tankattack`
- `/bc tank attack`
- `/bc tank-attack`
- `/bc tank_attack`
- `/bc attackdps`
- `/bc attack dps`
- `/bc passive`
- `/bc passive dps`
- `/bc help`

Les alias avec espaces, tirets et underscores sont toujours normalises.

## Execution des actions

Le point d'entree UI et slash reste :

- `BotControl_RunNamedAction(actionKey)`

Puis :

1. l'action est resolue dans `BotControl.ACTION_BY_KEY`
2. `BotControlActions:RunAction(actionKey)` lit le registre
3. si l'action declare `sequence`, chaque action de la sequence est lancee
4. sinon le `builder` est appele
5. `PrepareCommands()` developpe les tokens de role
6. l'execution passe par :
   - `BotControl.RunCommands(...)`
   - ou `BotControl.RunCommandsQueued(...)` si `queued = true`

Cas particuliers conserves :

- `InitBots` reste queuee
- `FullSetup` lance `Build` puis `Init`

## Ajouter un nouveau bouton d'action

Pour ajouter une action simple, il faut maintenant :

1. ajouter une entree dans `BotControl.ActionRegistry`
2. ajouter un builder dans `BotControl_Actions.lua` seulement si l'action a une logique nouvelle

Il ne faut plus modifier manuellement :

- le layout
- `ACTION_BUTTON_CONFIG`
- `ACTION_COMMAND_ORDER`
- `ACTION_COMMAND_ALIASES`
- la creation du bouton
- l'enregistrement dans `BotControl_ActionElements`
- l'enregistrement dans `BotControl_ActionConfigElements`
- l'enregistrement dans `BotControl_ActionCombatElements`

### Exemple complet

Ajouter cette entree dans `BotControl.ActionRegistry` :

```lua
{
    key = "MyNewAction",
    label = "Mon action",
    tooltipTitle = "Mon action",
    tooltipDescription = "Lance une commande de test",
    texture = "Interface\\Icons\\INV_Misc_QuestionMark",
    tab = "Combat",
    group = "All",
    order = 100,
    aliases = { "mynewaction", "my new action" },
    builder = "MyNewActionCommands",
    queued = false
}
```

Puis ajouter le builder :

```lua
function BotControlActions:MyNewActionCommands()
    local commands = {}

    AddParty(commands, "follow")

    return commands
end
```

C'est tout.

Le bouton sera :

- cree automatiquement
- stylise automatiquement
- visible dans le bon sous-onglet
- place automatiquement dans le layout
- disponible via `/bc mynewaction`

## Champs utiles du registre

- `key`
  Cle interne unique.
- `label`
  Texte logique du bouton.
- `tooltipTitle`
  Titre du tooltip.
- `tooltipDescription`
  Description du tooltip.
- `texture`
  Texture d'icone.
- `tab`
  `Config` ou `Combat`.
- `group`
  `Config`, `Tank`, `DPS`, `Heal` ou `All`.
- `order`
  Ordre d'affichage.
- `aliases`
  Alias slash explicites.
- `builder`
  Nom de la fonction `...Commands()`.
- `queued`
  Utilise `RunCommandsQueued`.
- `sequence`
  Sequence d'actions au lieu d'un builder direct.
- `buttonName`
  Optionnel. Sert seulement a rebrancher un bouton historique deja nomme autrement.

## Compatibilite

La refonte conserve :

- la compatibilite WoW 2.4.3 / Lua 5.1
- les builders existants
- les sous-onglets `Config` et `Combat`
- les groupes visuels `Tank / DPS / Heal / All`
- les slash commands `/bc ...`
- la normalisation des alias
- les wrappers globaux `BotControl_Action_<Key>`
- les noms globaux de boutons historiques quand ils existent deja

Les boutons historiques definis en XML sont reutilises.
Les nouveaux boutons suivent par defaut la convention :

- `BotControl<Key>Button`

## Actions actuellement declarees

Config :

- `ComposeGroup`
- `Build`
- `Init`
- `FullSetup`
- `Summon`
- `InitBots`

Combat :

- `TankAttack`
- `AttackDPS`
- `PassiveDPS`
- `Follow`
- `Passive`
- `Stay`
- `Used`
