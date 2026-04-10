import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/pet_controller.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja do Pet'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: controller.storeItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = controller.storeItems[index];
          final owned = controller.ownedItems[item.id] ?? false;
          final isEquipped = controller.selectedAccessory == item.id;
          final canAfford = controller.pet.coins >= item.price;
          final inInventory = controller.inventoryCount(item.id);
          final atMaxStack = item.maxStack > 0 && inInventory >= item.maxStack;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: owned || inInventory > 0
                            ? Colors.amber.shade100
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Text(item.icon, style: const TextStyle(fontSize: 24)),
                      ),
                      if (inInventory > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade700,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Text(
                              '$inInventory',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(item.description),
                        const SizedBox(height: 8),
                        if (!item.isCosmetic && item.maxStack > 0)
                          Text('${item.price} 💰  •  máx. ${item.maxStack} no inventário',
                              style: Theme.of(context).textTheme.labelMedium)
                        else if (!owned)
                          Text('Preço: ${item.price} 💰',
                              style: Theme.of(context).textTheme.labelLarge)
                        else
                          Row(children: [
                            const Icon(Icons.check_circle, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text('Possuído',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: Colors.green)),
                          ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.isCosmetic) ...[
                    if (isEquipped)
                      FilledButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Equipado'),
                      )
                    else if (owned)
                      ElevatedButton(
                        onPressed: () => controller.equipAccessory(item.id),
                        child: const Text('Equipar'),
                      )
                    else
                      ElevatedButton(
                        onPressed: canAfford
                            ? () => controller.buyItem(item.id)
                            : null,
                        child: Text('${item.price} 💰'),
                      ),
                  ] else ...[
                    // Consumable: buy goes to inventory
                    ElevatedButton(
                      onPressed: canAfford && !atMaxStack
                          ? () => controller.buyItem(item.id)
                          : null,
                      child: atMaxStack
                          ? const Text('Cheio')
                          : canAfford
                              ? const Text('Comprar')
                              : const Text('Sem moedas'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
