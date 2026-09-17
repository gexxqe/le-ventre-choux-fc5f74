# Le Ventre à Choux — Web

Première version web responsive de l'application.

## Lancer localement

La version actuelle n'utilise aucun framework ni build step.

1. Ouvrir `web/index.html` directement dans un navigateur, ou
2. Depuis le dossier `web`, lancer un petit serveur local, par exemple :

```bash
python -m http.server 8080
```

Puis ouvrir `http://localhost:8080`.

## Fonctionnalités v1

- Accueil responsive inspiré de l'application iOS
- Menu avec filtres par catégorie
- Horaires et statut ouvert/fermé calculé côté navigateur
- Boutons téléphone et itinéraire
- Formulaire de réservation
- Sauvegarde temporaire des demandes dans `localStorage`
- Avis clients et informations de contact
- Navigation adaptée ordinateur et mobile

## Prochaine étape

Brancher les réservations, le menu et les réglages à un backend commun afin que les versions iOS et web utilisent les mêmes données.
