# Documentation

## Guide de rédaction {#writing-guide}

GeoCat a fourni un [guide d\'écriture](https://geocat.github.io/geocat-themes/) pour la documentation sphinx. Bien que les conventions d\'écriture doivent être respectées, l\'adaptation des directives sphinx au formatage markdown nécessite un certain travail.

Lors de la conversion en markdown, nous pouvons nous concentrer uniquement sur l\'aspect visuel, en convertissant de nombreuses directives sphinx en leur équivalent visuel le plus proche :

| Markdown                 | Directive Sphinx                       |
|--------------------------|----------------------------------------|
| `**strong **`            | gui-label, menuselection               |
| `` `monospace` ``        | saisie de texte, sélection d\'éléments |
| `*accentuation*`         | chiffre (légende)                      |
| `***strong-emphasis***`  | commande                               |
| `` `monospace-strong` `` | fichier                                |

Veuillez noter que les conventions ci-dessus sont importantes pour la cohérence et sont requises par le processus de traduction.

### Composants de l\'interface utilisateur {#user-interface-components}

Utilisez `**strong**` pour nommer les composants de l\'interface utilisateur pour l\'interaction (appuyez pour les boutons, cliquez pour les liens).

Avant-première :

> Accédez à la page **Couches de données** et cliquez sur **Ajouter** pour créer une nouvelle couche.

Markdown :

```markdown
Naviguez jusqu'à la page **Calques de données**, et appuyez sur **Ajouter** pour créer un nouveau calque.
```

Texte riche et structuré :

```rst
Naviguez vers la page :menuselection:`Data Layers`, et appuyez sur :guilabel:`Add`` pour créer une nouvelle couche.
```

### Données de l\'utilisateur {#user-input}

Utilisez `` `item` `` pour les données fournies par l\'utilisateur, ou les éléments d\'une liste ou d\'un arbre: :

Avant-première :

> Sélectionnez la couche `Basemap`.

Markdown :

```markdown
Sélectionnez la couche `Basemap`.
```

Texte riche et structuré :

```
Sélectionnez la couche "Basemap".
```

Utilisez `` `text` `` pour le texte fourni par l\'utilisateur :

Avant-première :

> Utilisez le champ de *recherche* pour saisir `Ocean*`.

Markdown :

```markdown
Utilisez le champ *Recherche* et entrez `Ocean*`.
```

Texte riche et structuré :

```
Utilisez le champ :guilabel:`Serach` pour entrer :kbd:`Ocean*`.
```

Utilisez `++key++` pour les touches du clavier.

Avant-première :

> Appuyez sur ++Control-s++ pour effectuer une recherche.

Markdown :

```markdown
Appuyez sur ++contrôle+s++ pour effectuer une recherche.
```

Texte riche et structuré :

```
Appuyez sur :key:``Control-s`` pour effectuer une recherche.
```

Utilisez une liste de définitions pour documenter la saisie des données. Les noms des champs utilisent strong car ils nomment un élément de l\'interface utilisateur. Les valeurs des champs à saisir utilisent monspace car il s\'agit d\'une entrée utilisateur à saisir.

Avant-première :

1.  Pour vous connecter en tant qu\'administrateur du GeoServer en utilisant le mot de passe par défaut :

    **Utilisateur**

    :   `l'administration`

    **Mot de passe**

    :   `geoserveur`

    **Souvenez-vous de moi**

    :   Non vérifié

    **Connexion** presse.

Markdown : listes de définitions

```
1.  Pour vous connecter en tant qu'administrateur de GeoServer en utilisant le mot de passe par défaut : **Utilisateur** : `admin` **Mot de passe** : `geoserver` **Souvenir de moi** : Non coché Appuyez sur **Login**.
```

Texte structuré riche : liste-tableau

```
#. Pour vous connecter en tant qu'administrateur GeoServer en utilisant le mot de passe par défaut : .. list-table: : :widths : 30 70 :width : 100% :stub-columns : 1 * - User : - :kbd:`admin` * - Password : - :kbd:`geoserver` * - Remember me - Unchecked Press :guilabel:`Login`.
```

### Applications, commandes et outils {#applications-commands-and-tools}

Utilisez les **caractères gras** et *italiques* pour les noms propres d\'applications, de commandes, d\'outils et de produits.

Avant-première :

Lancez ***pgAdmin*** et connectez-vous au `didacticiel sur` les données.

Markdown :

```markdown
Lancez ***pgAdmin*** et connectez-vous à la base de données `tutorial`.
```

Texte riche et structuré :

```
Lancez :command:`pgAdmin` et connectez-vous à la base de données ``tutorial``.
```

### Fichiers {#files}

Utilisez le **gras** **monospace** pour les fichiers et les dossiers :

Aperçu Voir le fichier de configuration **`WEB-INF/config-security/config-security-ldap.xml`** pour plus de détails.

Markdown :

```markdown
Voir le fichier de configuration **`WEB-INF/config-security/config-security-ldap.xml`** pour plus de détails.
```

Texte riche et structuré :

```
Voir le fichier de configuration :file:`WEB-INF/config-security/config-security-ldap.xml` pour plus de détails.
```

### Liens et références {#links-and-references}

Types de liens spécifiques :

Référence à une autre section du document (une certaine attention est requise pour faire référence à un titre spécifique) :

Les éditeurs ont la possibilité de [gérer les](../editor/publish/index.md#publish-records) enregistrements.

```
Les éditeurs ont la possibilité de :ref:`gérer les enregistrements <Publish records>`. Les éditeurs ont la possibilité de [gérer](../editor/publish/index.md#publish-records) les enregistrements.
```

Téléchargement de fichiers d\'échantillons :

Exemple :

Téléchargez le schéma [**`example.xsd`**](files/example.xsd).

```
Téléchargez le schéma :download:`example.xsd <files/example.xsd>`. Téléchargez le schéma [**`example.xsd`**](files/example.xsd).
```

### Icônes, images et figures {#icons-images-and-figures}

Material for markdown dispose d\'une prise en charge étendue des icônes. Pour la plupart des éléments de l\'interface utilisateur, il est possible d\'utiliser directement l\'icône appropriée dans Markdown :

```markdown
1.  Appuyez sur le bouton *Valider :fontawesome-solid-check:* en haut de la page.
```

Ajouter les icônes cusotm à **`overrides/.icons/geocat`**:

```markdown
L'équipe GeoCat vous remercie :geocat-logo :
```

Les figures sont traitées par convention, en ajoutant un texte en relief après chaque image et en faisant confiance aux règles CSS pour assurer une présentation cohérente :

```markdown
![](img/begin_date.png) *Valeur obligatoire pour la date de début*
```

Les images brutes ne sont pas utilisées très souvent :

```markdown
![](img/geocat-logo.png)
```

### Tableaux {#tables}

La documentation n\'utilise que des tables de pipes (supportées par ***mkdocs*** et ***pandoc***) :

Plombage / talonnage `|`:

| Première tête      | Deuxième en-tête   | Troisième en-tête  |
|--------------------|--------------------|--------------------|
| Cellule de contenu | Cellule de contenu | Cellule de contenu |
| Cellule de contenu | Cellule de contenu | Cellule de contenu |

Alignement des colonnes à l\'aide de `:`

| Première tête | Deuxième en-tête | Troisième en-tête |
|:--------------|:----------------:|------------------:|
| Gauche        |      Centre      |             Droit |
| Gauche        |      Centre      |             Droit |

## Traduction {#translation}

La traduction utilise ***pandoc*** pour convertir en `html` pour la conversion par ***Deepl***.

Des extensions spécifiques de ***pandoc*** sont utilisées pour s\'adapter aux capacités de ***mkdocs***.

| extension mkdocs | extension pandoc |
|------------------|------------------|
| tables           | tables_pipe      |

D\'autres différences dans le markdown nécessitent un traitement avant/après des fichiers markdown et html. Ces étapes sont automatisées dans le script python ***translate*** (consultez les commentaires pour plus de détails).

Pour traduire une variable environnementale en clé d\'authentification Deepl :

```
export DEEPL_AUTH="xxxxxxxx-xxx-...-xxxxx:fx"
```

Pour tester chaque étape individuellement :

```
python3 -m translate html docs/devel/docs/docs.md python3 -m translate document target/translate/devel/docs/docs.html target/translate/devel/docs/docs.fr.html python3 -m translate markdown target/translate/devel/docs/docs.fr.html cp target/translate/devel/docs/docs.fr.md docs/devel/docs/docs.fr.md
```

Pour tester les formats markdown / html uniquement :

```
python3 -m translate convert docs/devel/docs/docs.md python3 -m translate markdown target/translate/devel/docs/docs.html diff docs/devel/docs/docs.md target/translate/devel/docs/docs.md 
```
