# BotControl 1.1.0 — WoW TBC 2.4.3

Composition de groupes et barre indépendante pour piloter les playerbots.
Version construite à partir de la branche 2.4.3 du dépôt loicberland/BotControl,
consultée le 2 octobre 2026.

## Installation

1. Quitter complètement WoW.
2. Remplacer le dossier `Interface/AddOns/BotControl` par celui du ZIP.
3. Vérifier le chemin : `Interface/AddOns/BotControl/BotControl.toc`.
4. Relancer le jeu. La barre apparaît vers le centre, légèrement en dessous.

Les profils et compositions existants sont conservés. Ne pas supprimer les
fichiers BotControl des dossiers `WTF/.../SavedVariables`.

## Profils et formats 5 / 10 / 25

Le premier bouton de la barre affiche le format actif : 5, 10 ou 25.

- Clic gauche : ouvrir/fermer la fenêtre de composition.
- Clic droit : ouvrir/fermer les réglages de la barre.
- `/bc` ou `/botcontrol` : ouvrir/fermer la fenêtre de composition.
- `/bc options` ou `/bc barre` : ouvrir/fermer les réglages.

Dans la fenêtre Profils, sélectionner 5, 10 ou 25 joueurs, puis sélectionner
un profil enregistré et utiliser son bouton de chargement, comme auparavant.
Les listes contiennent respectivement 4, 9 ou 24 bots : le joueur occupe la
place restante. Modifier le format ou charger un profil n'invite personne.
Le bouton « Composer le groupe » lance les commandes de composition existantes.
« Appliquer » sauvegarde la composition courante ; le bouton de sauvegarde de
profil l'enregistre sous le nom saisi. Fermer la fenêtre conserve aussi les
modifications de la composition courante.

L'infobulle du premier bouton indique le dernier profil chargé/enregistré pour
le format actif. La composition peut avoir été retouchée depuis son chargement.
Un simple clic dans la liste de profils ne change pas ce dernier profil chargé.

## Barre d'actions

Cinq catégories fixes : Config du groupe, Tank, DPS, Heal et Général.

| Bouton | Clic gauche | Clic droit |
| --- | --- | --- |
| Principal d'une catégorie | Exécuter l'action affichée | Ouvrir/fermer le sous-menu |
| Action du sous-menu | Exécuter et laisser le menu ouvert | Définir comme principal et fermer ce menu |
| Raccourci personnalisé | Exécuter | Choisir son affectation |
| Raccourci vide | Choisir son affectation | Choisir son affectation |

Plusieurs sous-menus peuvent rester ouverts simultanément. Ils ne se ferment
ni au déplacement de la souris, ni au clic ailleurs, ni après un délai.
Un petit astérisque repère l'action principale dans chaque sous-menu.
Les menus sont fermés au démarrage/rechargement, mais les actions principales
choisies sont conservées.

Les initialisations Tank et Heal se trouvent dans leur catégorie respective.
Les commandes slash et fonctions historiques sont conservées. Exemples :
`/bc tankattack`, `/bc attackdps`, `/bc follow`, `/bc stay`, `/bc help`.

## Réglages

- Barre horizontale ou verticale.
- Sous-menus perpendiculaires : haut/bas ou gauche/droite.
- Taille des boutons : 24 à 64 pixels.
- Espacement : 0 à 16 pixels.
- Raccourcis personnalisés : 0 à 10, issus de n'importe quelle catégorie.
- Position verrouillable. Déverrouiller pour afficher la poignée de déplacement.
- Bouton « Recentrer la barre » si nécessaire.
- Libellés courts facultatifs : Grp, Cfg, Tank, DPS, Heal, Gen et P1…P10.

Les raccourcis s'affectent soit par clic droit directement sur la barre, soit
par les boutons de la fenêtre Réglages. Le sélecteur permet de filtrer par
catégorie et de vider un emplacement. Réduire leur nombre masque les derniers
emplacements sans effacer leurs affectations.

Position, apparence, principaux et raccourcis sont sauvegardés par personnage,
dans `BotControlCharacterDB.actionBar`, indépendamment des compositions 5/10/25.
Changer de profil ne réorganise pas la barre.

Choisir un sens d'ouverture et une taille compatibles avec la place disponible
sur l'écran, en particulier avec dix raccourcis sur une barre verticale.

## Ajouter une action dans le code

Les actions sont définies dans `BotControl_ActionRegistry.lua`.
Le champ `group` décide de la catégorie de la barre :

| Valeur | Catégorie |
| --- | --- |
| `Config` | Config du groupe |
| `Tank` | Tank |
| `DPS` | DPS |
| `Heal` | Heal |
| `All` | Général |

`order` décide de l'ordre dans le sous-menu. `key` est l'identifiant stable
sauvegardé pour les boutons principaux et les raccourcis : éviter de le renommer.
Conserver `tab = "Config"` pour Config, `tab = "Combat"` pour les autres catégories,
pour la compatibilité avec les anciennes tables et l'aide.

Exemple à ajouter au registre :

```lua
{
    key = "MyNewAction",
    label = "Mon action",
    tooltipTitle = "Mon action",
    tooltipDescription = "Ordonne au groupe de suivre",
    texture = "Interface\\Icons\\Ability_Hunter_Pathfinding",
    tab = "Combat",
    group = "All",
    order = 100,
    aliases = { "mynewaction" },
    builder = "MyNewActionCommands",
    queued = false
}
```

Puis dans `BotControl_Actions.lua`, où `AddParty` est disponible :

```lua
function BotControlActions:MyNewActionCommands()
    local commands = {}
    AddParty(commands, "follow")
    return commands
end
```

Après `/reload`, l'action apparaît dans le sous-menu Général, dans le sélecteur
de raccourcis et via `/bc mynewaction`. Aucun bouton à créer manuellement.
Le sélecteur est paginé pour accepter de nouvelles actions.

## Organisation des fichiers

- `BotControl_Bar.lua` : barre, sous-menus, sélecteur et réglages.
- `BotControl_ActionRegistry.lua` : définition et classement des actions.
- `BotControl_Actions.lua` : génération et exécution des commandes.
- `BotControl.lua` : composition, profils, commandes slash et moteur existant.
- `BotControl_Config.lua` : stockage des données.
- `BotControl.xml` : fenêtre de composition et contrôles historiques.

## Corrections associées

Deux raccordements existants ont été corrigés dans le registre :
- `WaitHEAL` appelle maintenant `WaitHEALCommands` (attente), et non la fuite.
- `HealFlee` appelle `FleeHEALCommands`, avec la casse du vrai nom de fonction.

Les commandes serveur et leurs délais restent ceux de la version d'origine.
La nouvelle barre utilise le même moteur d'envoi, y compris pour les séquences.

## Validation

Syntaxe de tous les fichiers Lua vérifiée avec le parseur Lua 5.4 disponible ;
le code ajouté utilise la syntaxe et les API prévues pour Lua 5.1 / WoW 2.4.3.
Simulation hors jeu : migration d'une configuration existante, sauvegarde et
chargement des profils, formats 5/10/25, clics, menus indépendants, choix du
principal, raccourcis 0 à 10, quatre sens d'ouverture, réglages, dispatch des
commandes et persistance après rechargement.

Le client WoW 2.4.3 n'est pas disponible dans cet environnement : rendu final,
interactions réelles et réponse des bots restent à vérifier en jeu, notamment
pendant un combat. Aucun test dans le client n'est revendiqué.
