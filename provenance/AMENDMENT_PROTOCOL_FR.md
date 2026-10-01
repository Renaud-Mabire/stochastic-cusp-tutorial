# Amendement interne : vérification finale de trois jeux fixes

Version 1.0.0 — 23 septembre 2026 — `CUSP_FIXED_CANDIDATES_20260923`.

## 1. Autorisation et portée

Après examen des résultats du protocole 1.0.1 et discussion de la possibilité de retenir un exemple individuel avec erreurs standards et p-values, Renaud a autorisé la préparation de ce complément. **Ce choix est postérieur aux résultats antérieurs ; il n'est pas préenregistré.** Le présent document fixe son implémentation avant la nouvelle exécution par Renaud.

Le protocole historique testait notamment la stabilité d'une configuration sur 30 réalisations, avec un seuil de 29 réalisations stables. D0 avait trois réalisations admises aux contrôles individuels disponibles. Le verdict historique `AWAIT_PACKAGE_CLARIFICATION` et l'échec du critère agrégé sont conservés sans modification.

La question est maintenant plus étroite : peut-on fournir un jeu fixe, accompagné de sa provenance et de ses limites, dont les sorties natives sont reproductibles et compatibles avec la référence numérique ? La sélection de ce jeu pour sa stabilité doit être déclarée dans le tutoriel. Une réussite ne justifiera ni de promettre la même stabilité après changement de graine, ni d'assimiler l'exemple sélectionné à un échantillon aléatoire non sélectionné pour étudier la performance inférentielle.

## 2. Entrées, modèle et départs

Les seuls jeux autorisés sont `D0_screen_28062027`, `D0_screen_28062028`, `D0_screen_28062029`, déjà enregistrés. Aucun appel de génération ni changement de données, de taille, de paramètres, de modèle ou de version du package. D0 : N = 1 200 ; prédicteurs indépendants normaux tronqués dans [-2,5 ; 2,5] ; alpha = 0 + 0,8 R ; beta = 0,25 + 1 S ; état initialement tiré par `rcusp()` ; scores présentés sous la transformation 50 + 10 fois la variable canonique. Les données d'analyse standardisées et leurs constantes sont celles des archives.

Modèle : `y ~ adaptive_functioning_z`, `alpha ~ personal_resources_z`, `beta ~ acute_stress_z`. Fonction publique `cusp::cusp()`, version 2.3.8 non modifiée, `optim.method = "L-BFGS-B"`. Aucun argument de précision interne ni aucune Hessienne externe n'est injecté dans cet appel.

Ordre des six paramètres initiaux internes : deux pour alpha, deux pour beta, deux pour l'état.

| Départ | Valeurs |
|---|---|
| primary | argument `start` omis ; défaut du package : (0 ; 0 ; 0,5 ; 0,5 ; 0 ; 1) |
| plus | (0,1 ; 0,1 ; 0,6 ; 0,4 ; 0,1 ; 1,1) |
| minus | (-0,1 ; -0,1 ; 0,4 ; 0,6 ; -0,1 ; 0,9) |

Trois nouveaux appels par jeu, dans trois processus R distincts. Les neuf anciens ajustements sont relus, sans réajustement, pour former trois ensembles de six solutions. Les graines sont conservées comme identifiants et fixées dans les processus ; aucun tirage de données n'est effectué. Le nouvel objet principal sans `start` sera celui montré au lectorat s'il est admis.

## 3. Critères nécessaires : sortie native

Les seuils individuels sont repris du protocole précédent. Ils constituent des tolérances pratiques pour cet exemple, et non des constantes universelles de validité d'un estimateur.

| Contrôle | Règle nécessaire | Justification |
|---|---|---|
| Ajustement individuel | Statut exploitable, `converged = TRUE`, code 0, rang 6, valeurs finies | Exclure les sorties non abouties ou incomplètes |
| Bornes internes | Distance relative à chaque borne > 1e-6, divisée par max(1, valeur absolue de la borne) | Exclure une solution contrainte active |
| `fit$OK` | TRUE dans les six objets, avec tous les autres contrôles | Condition nécessaire, jamais preuve suffisante |
| Hessiennes natives | Matrices interne et transformée strictement positives ; ratio min/max des valeurs propres internes > 1e-8 | Écarter l'indéfinitude et un conditionnement interne ≥ 1e8 ; conditionnement transformé enregistré |
| Table native | Six lignes ; estimations, SE, z et p finis ; toutes SE > 0 | Table complète effectivement calculable |
| Vraisemblance | Étendue de NLL entre les six solutions ≤ 0,01 | Écart faible à l'échelle de la vraisemblance totale |
| Coefficients | Pour chaque coefficient, étendue ≤ 0,02 et ≤ 0,10 fois la médiane des six SE | Accord absolu et faible par rapport à l'incertitude native |
| SE | Pour chaque coefficient, (max − min) / médiane ≤ 10 % | Reproductibilité pratique des colonnes dérivées |
| Coordonnées | Pour chaque paire de solutions et alpha, beta, état : RMSE / écart-type des coordonnées de l'ancien primary ≤ 0,02 | Géométrie presque inchangée |
| Région bistable | Accord des classifications ≥ 99 % et différence de proportion ≤ 0,01, pour chaque paire | Stabilité de l'illustration de la région |

Ces règles sont appliquées aux six objets ensemble ; les bilans de trois anciens et trois nouveaux sont également exportés. La positivité est examinée sur la partie symétrisée de chaque matrice ; l'asymétrie maximale est enregistrée.

Le bloc de coefficients est extrait selon les opérations exactes de `summary.cusp` 2.3.8 : inversion issue de `fit$qr`, rétablissement de l'ordre, SE = racine des variances diagonales, z = coefficient / SE, p = 2 Phi(-|z|). **Aucun intervalle de confiance n'est supposé fourni par summary().** Les z, plages de p et éventuels franchissements de 0,05 sont exportés pour interprétation, sans filtre fondé sur la significativité. Le passage d'une p-value autour de 0,05 ne doit pas être présenté comme une conclusion catégorique stable. La stabilité des SE n'implique pas l'identité des p-values chiffre par chiffre.

## 4. Critères nécessaires : vérité et intérêt pédagogique

Pour l'ancien et le nouveau primary séparément : pentes alpha-ressources, beta-stress et transformation de l'état positives ; RMSE des coordonnées alpha, beta, état, divisée par l'écart-type de la vérité correspondante, ≤ 0,25 pour chacune. Exactitude de la classification bistable ≥ 90 %, sensibilité ≥ 70 %, spécificité ≥ 90 %. Proportion ajustée en région bistable entre 10 et 40 % inclus.

Ces critères antérieurs visent une représentation reconnaissable de la géométrie et des deux régions, avec récupération raisonnable sur une réalisation. Les écarts de chaque coefficient à sa vérité sur l'échelle d'analyse sont exportés. Aucun critère de significativité n'est ajouté. La couverture et le taux de faux positifs ne sont pas estimés : trois exemples présélectionnés ne permettraient pas de les évaluer valablement.

## 5. Référence externe, niveau B

Pour chaque nouveau primary satisfaisant les contrôles ponctuels, le module historique de référence est repris sans changement scientifique. Un primary ponctuellement invalide rend déjà le candidat inadmissible ; sa référence est explicitement marquée non exécutée.

La référence utilise la même formule de vraisemblance et la routine de normalisation fournie avec cusp, avec tolérance 1e-9 et 1 000 subdivisions. Elle est donc un contrôle numérique plus précis, pas une implémentation théorique indépendante. Un contrôle préalable doit reproduire la NLL native à 1e-8 avec les réglages par défaut ; l'identité de la transformation des coefficients est contrôlée à 1e-10. Une discordance est une erreur technique, pas une preuve contre le candidat.

Au **point natif exact**, trois Hessiennes de référence sont calculées aux pas relatifs 1e-3, 5e-4, 2,5e-4. Elles doivent toutes avoir leurs matrices interne et transformée positives, leur ratio interne min/max > 1e-8 et des SE positives finies. Pour chaque coefficient, l'étendue des SE de référence / leur médiane doit être ≤ 5 %. L'écart absolu entre la SE native et cette médiane / cette médiane doit être ≤ 10 %. Cette comparaison empêche d'admettre une courbure native seulement reproductible mais éloignée du calcul plus précis.

Une seule continuation de référence part de ce primary, sans recherche supplémentaire de départs. La perte de NLL du point natif par rapport à cette continuation doit être ≤ 0,01 ; les écarts de coefficients doivent être ≤ 0,02 et ≤ 0,10 SE de référence. Le critère de perte est orienté comme dans le protocole antérieur ; une référence moins favorable est signalée séparément dans les exports et doit être examinée lors de la revue.

La stationnarité au point poursuivi est contrôlée avec les trois mêmes pas et les tolérances de normalisation 1e-7 et 1e-9. Les gradients bruts des deux pas les plus fins doivent avoir une norme maximale ≤ 1e-3. L'enveloppe conservatrice formée du maximum des extrapolations de Richardson, de leur écart entre pas et de leur écart entre tolérances doit aussi être ≤ 1e-3. Aucune borne active ; aucun code d'intégration non nul ni normalisateur invalide dans les évaluations contrôlées. Le code de la continuation est enregistré ; sa décision repose sur stationnarité, bornes et intégration, conformément au module antérieur.

Le recours à Richardson prolonge l'amendement interne terminal 1.1 ; il n'est jamais qualifié de préenregistrement. Les résultats de référence restent séparés. Ni coefficients, ni Hessienne, ni covariance de l'objet natif ne sont remplacés.

## 6. Sélection et vraie sortie standard

Les trois candidats sont examinés, même si le premier passe. Le premier satisfaisant **tous** les critères natifs, pédagogiques et de référence dans l'ordre 28062027, 28062028, 28062029 est verrouillé. L'ordre ne dépend ni de l'AIC/BIC, ni des p-values, ni des graphiques.

Après ce verrouillage seulement : vrais `summary(fit, logist = FALSE)` des six objets du candidat retenu. Leur bloc de coefficients doit correspondre à l'extraction utilisée pour les diagnostics, avec écart |table − extraction| / max(1, |extraction|) ≤ 1e-8. Il s'agit d'un contrôle technique d'identité de calcul, distinct des tolérances entre ajustements.

Les statistiques comparatives automatiquement calculées par summary() sont conservées telles quelles, sans servir à sélectionner le candidat. Aucun nouveau comparateur quadratique/logistique. Le test chi-deux imprimé par le package n'est pas validé par ces contrôles. Les graphiques publics `plot(fit)` et `cusp3d(fit)`, ainsi que trois profils conditionnels fixes via `dcusp()`, sont exportés pour le seul nouveau primary. Leur examen visuel intervient lors de la revue de l'archive.

Si summary() ne reproduit pas la table attendue ou si une sortie obligatoire échoue, l'exécution est incomplète et doit être auditée. Le programme ne passe pas opportunément au candidat suivant après verrouillage.

## 7. Environnement, arrêts et décision

R natif macOS obligatoire ; cusp exactement 2.3.8 ; contrôles d'intégrité des entrées et du code. R 4.6.0 est recommandé pour la continuité ; une autre version native n'est pas rejetée pour son seul numéro. Elle est enregistrée et les mêmes tolérances entre les anciens et les nouveaux ajustements s'appliquent. Un succès sur ce Mac n'établit pas une reproductibilité sur tous les systèmes.

Chaque processus a une limite technique de 1 800 secondes. Erreur inattendue, entrée non conforme, interruption, dépassement de durée ou sortie manquante : `INCOMPLETE_TECHNICAL_ERROR`, **aucune décision scientifique**, correction technique versionnée avant relance. Un échec numérique reconnu est enregistré comme résultat scientifique d'un ajustement ; il ne déclenche pas un remplacement de graine. Aucune extension automatique de la liste ou du protocole.

| Exécution complète | Recommandation automatique provisoire |
|---|---|
| Un candidat réussit, puis ses sorties standard sont vérifiées | `KEEP_CURRENT_DGP_STANDARD_OUTPUT`, **exclusivement pour le jeu fixe retenu** |
| Aucun des trois candidats ne satisfait les critères | `AWAIT_PACKAGE_CLARIFICATION` |

Le premier libellé est réutilisé pour respecter les catégories finales demandées, avec une portée explicitement amendée : `selection_scope = FIXED_DATASET_ONLY_NOT_DGP_VALIDATION` et `generator_aggregate_admitted = FALSE`. Il n'annule ni ne remplace la catégorie historique. `ADOPT_NEW_DGP_STANDARD_OUTPUT` est hors champ, puisque le générateur ne change pas. `POINT_ESTIMATES_ONLY` n'est pas une solution de repli ici : le tutoriel exige SE et p-values.

La décision finale appartient à la revue de l'archive complète produite par Renaud. Aucun résultat attendu n'est présumé dans ce projet.
