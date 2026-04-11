import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pet_controller.dart';
import '../models/store_item.dart';
import '../services/locale_controller.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PetController>(context);
    final s = context.watch<LocaleController>().s;

    // Only consumable items that the player holds at least 1 of
    final consumables = controller.storeItems
        .where((item) => !item.isCosmetic)
        .toList();

    final heldItems = consumables
        .where((item) => (controller.inventory[item.id] ?? 0) > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('🎒 ${s.inventoryTitle}'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _InventoryHeader(heldItems: heldItems, controller: controller),
          Expanded(
            child: heldItems.isEmpty
                ? const _EmptyInventory()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    itemCount: consumables.length,
                    itemBuilder: (context, i) {
                      final item = consumables[i];
                      final count = controller.inventory[item.id] ?? 0;
                      return _InventoryItemTile(
                        item: item,
                        count: count,
                        onUse: count > 0
                            ? () => controller.useItem(item.id)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _InventoryHeader extends StatelessWidget {
  final List<StoreItem> heldItems;
  final PetController controller;

  const _InventoryHeader(
      {required this.heldItems, required this.controller});

  @override
  Widget build(BuildContext context) {
    final totalSlots = heldItems.fold<int>(
        0, (sum, item) => sum + (controller.inventory[item.id] ?? 0));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.cyan.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$totalSlots item${totalSlots == 1 ? '' : 's'} ${context.watch<LocaleController>().isPt ? 'guardado${totalSlots == 1 ? '' : 's'}' : 'stored'}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            context.watch<LocaleController>().isPt
                ? 'Use itens para ajudar seu pet na hora certa!'
                : 'Use items to help your pet at the right time!',
            style:
                const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            context.watch<LocaleController>().s.inventoryEmpty,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            context.watch<LocaleController>().isPt
                ? 'Compre consumíveis na loja!'
                : 'Buy consumables at the store!',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _InventoryItemTile extends StatelessWidget {
  final StoreItem item;
  final int count;
  final VoidCallback? onUse;

  const _InventoryItemTile({
    required this.item,
    required this.count,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final hasItem = count > 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: hasItem ? null : Colors.grey.shade100,
      elevation: hasItem ? 2 : 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon with count badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasItem
                        ? Colors.teal.shade50
                        : Colors.grey.shade200,
                  ),
                  child: Center(
                    child: Text(
                      item.icon,
                      style: TextStyle(
                          fontSize: 28,
                          color: hasItem ? null : const Color(0x88000000)),
                    ),
                  ),
                ),
                if (hasItem)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade700,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
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
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: hasItem ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    style: TextStyle(
                        fontSize: 12,
                        color: hasItem
                            ? Colors.grey.shade600
                            : Colors.grey.shade400),
                  ),
                  if (item.maxStack > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: count / item.maxStack,
                          minHeight: 5,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.teal.shade400),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasItem
                    ? Colors.teal.shade600
                    : Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onUse,
              child: Text(context.watch<LocaleController>().s.inventoryUse),
            ),
          ],
        ),
      ),
    );
  }
}
